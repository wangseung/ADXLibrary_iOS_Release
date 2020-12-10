//
//  MoPubCustomEventRewardedVideo.m
//  ADXLibrary
//
//  Created by 최치웅 on 2019. 1. 18..
//

#import "MoPubCustomEventRewardedVideo.h"
#import "GADMAdapterMoPubConstants.h"

#import "ADXLogUtil.h"

@interface MoPubCustomEventRewardedVideo() <MPRewardedVideoDelegate> {
    GADMediationRewardedLoadCompletionHandler _adLoadCompletionHandler;
    __weak id<GADMediationRewardedAdEventDelegate> _adEventDelegate;
}

@property(nonatomic, copy) NSString *adUnitId;

@end

@implementation MoPubCustomEventRewardedVideo

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err == nil && [result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    
    return nil;
}

#pragma mark GADMediationAdapter implementation

+ (GADVersionNumber)adSDKVersion {
  NSString *versionString = [[MoPub sharedInstance] version];
  NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];

  GADVersionNumber version = {0};
  if (versionComponents.count >= 3) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion = [versionComponents[2] integerValue];
  }
  return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  return Nil;
}

+ (GADVersionNumber)version {
  return [MoPubCustomEventRewardedVideo adapterVersion];
}

+ (GADVersionNumber)adapterVersion {
  NSArray *versionComponents = [kGADMAdapterMoPubVersion componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count >= 4) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion =
        [versionComponents[2] integerValue] * 100 + [versionComponents[3] integerValue];
  }
  return version;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    NSString *parameter = configuration.credentials[0].settings[@"parameter"];
    NSDictionary *info = [MoPubCustomEventRewardedVideo dictionaryWithJsonString:parameter];
    NSString *adUnitId = [info objectForKey:@"adunit_id"];
    
    NSString *errorMsg = nil;
    if (!adUnitId) errorMsg = @"Invalid MoPub adUnitId";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kGADErrorDomain
                                             code:kGADErrorInvalidArgument
                                         userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        completionHandler(error);
        return;
    }
    
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:adUnitId];
    
    if(![[MoPub sharedInstance] isSdkInitialized]) {
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig
                                                    completion:^{
                                                            completionHandler(nil);
                                                    }];
    } else {
        completionHandler(nil);
    }
}
                                  
- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_RV, ADX_EVENT_LOAD);
    
    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *info = [MoPubCustomEventRewardedVideo dictionaryWithJsonString:parameter];
    NSString *adUnitId = [info objectForKey:@"adunit_id"];
    
    self.adUnitId = adUnitId;
    
    _adLoadCompletionHandler = completionHandler;
    
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:adUnitId];
    
    if(![[MoPub sharedInstance] isSdkInitialized]) {
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig
                                                    completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MPRewardedVideo setDelegate:self forAdUnitId:self.adUnitId];
                [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:self.adUnitId withMediationSettings:nil];
            });
                                                    }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MPRewardedVideo setDelegate:self forAdUnitId:self.adUnitId];
            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:self.adUnitId withMediationSettings:nil];
        });
    }
}

#pragma mark GADMediationRewardedAd implementation

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:self.adUnitId]) {
        ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_RV, ADX_EVENT_IMPRESSION);
        
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:self.adUnitId fromViewController:viewController withReward:nil customData:nil];
        [_adEventDelegate willPresentFullScreenView];
        [_adEventDelegate didStartVideo];
    } else {
        NSLog(@"MoPub rewarded video ad was not available");
        NSError *error = [NSError errorWithDomain:kGADErrorDomain code:kGADErrorInternalError userInfo:nil];
        [_adEventDelegate didFailToPresentWithError:error];
    }
}

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_RV, ADX_EVENT_LOAD_SUCCESS);
    
    _adEventDelegate = _adLoadCompletionHandler((id) self, nil);
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_RV, errorMsg);
    
    _adLoadCompletionHandler(nil, error);
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID {
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate didFailToPresentWithError:error];
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID {
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID {
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate reportImpression];
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID {
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate willDismissFullScreenView];
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_RV, ADX_EVENT_CLOSED);
    
   id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate didEndVideo];
    [strongDelegate didDismissFullScreenView];
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_RV, ADX_EVENT_CLICK);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate reportClick];
}

- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_RV, ADX_EVENT_REWARD);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate didRewardUserWithReward:[[GADAdReward alloc] initWithRewardType:@"" rewardAmount:[NSDecimalNumber one]]];
}

@end
