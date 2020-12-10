//
//  AdMobCustomEventRewardedVideo.m
//  ADXLibrary
//
//  Created by 최치웅 on 19/07/2019.
//
#import "AdMobCustomEventRewardedVideo.h"

#import "ADXLogUtil.h"

@interface AdMobCustomEventRewardedVideo() <GADMediationRewardedAd> {
    GADRewardedAd *_rewardBasedVideoAd;
    __weak id<GADMediationRewardedAdEventDelegate> _adEventDelegate;
}

@property(nonatomic, copy) NSString *adUnitId;

@end

@implementation AdMobCustomEventRewardedVideo

+ (GADVersionNumber)adSDKVersion {
    NSString *versionString = @"1.0.0";
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

+ (GADVersionNumber)version {
    NSString *versionString = @"1.0.0";
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
      version.majorVersion = [versionComponents[0] integerValue];
      version.minorVersion = [versionComponents[1] integerValue];
      version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  return Nil;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    NSString *parameter = configuration.credentials[0].settings[@"parameter"];
    NSDictionary *info = [AdMobCustomEventRewardedVideo dictionaryWithJsonString:parameter];
    NSString *adUnitId = [info objectForKey:@"adunit_id"];
    
    NSString *errorMsg = nil;
    if (!adUnitId) errorMsg = @"Invalid AdMob adUnitId";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kGADErrorDomain
                                             code:kGADErrorInvalidArgument
                                         userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        completionHandler(error);
        return;
    }
    
    completionHandler(nil);
}
                                  
- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    
    ADXLogEvent(ADX_PLATFORM_ADMOB, ADX_INVENTORY_RV, ADX_EVENT_LOAD);
    
    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *info = [AdMobCustomEventRewardedVideo dictionaryWithJsonString:parameter];
    NSString *adUnitId = [info objectForKey:@"adunit_id"];
            
    self.adUnitId = adUnitId;
    
    GADRewardedAd *rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:self.adUnitId];
    
    GADRequest *request = [GADRequest request];
    [rewardedAd loadRequest:request completionHandler:^(GADRequestError * _Nullable error) {
        if (error) {
            NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
            ADXLogEvent(ADX_PLATFORM_ADMOB, ADX_INVENTORY_RV, errorMsg);
            
            completionHandler(nil, error);
        } else {
            ADXLogEvent(ADX_PLATFORM_ADMOB, ADX_INVENTORY_RV, ADX_EVENT_LOAD_SUCCESS);
            
            self->_rewardBasedVideoAd = rewardedAd;
            self->_adEventDelegate = completionHandler(self, nil);
        }
    }];
}
                                  
- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    if (_rewardBasedVideoAd.isReady) {
        [_rewardBasedVideoAd presentFromRootViewController:viewController delegate:(id) self];
        [_adEventDelegate willPresentFullScreenView];
        [_adEventDelegate didStartVideo];
    } else {
        NSLog(@"AdMob rewarded video ad was not available");
        NSError *error = [NSError errorWithDomain:kGADErrorDomain code:kGADErrorInternalError userInfo:nil];
        [_adEventDelegate didFailToPresentWithError:error];
    }
}

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

#pragma mark - GADRewardedAdDelegate
/// Tells the delegate that the user earned a reward.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    ADXLogEvent(ADX_PLATFORM_ADMOB, ADX_INVENTORY_RV, ADX_EVENT_REWARD);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate didRewardUserWithReward:reward];
}

/// Tells the delegate that the rewarded ad was presented.
- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
    ADXLogEvent(ADX_PLATFORM_ADMOB, ADX_INVENTORY_RV, ADX_EVENT_IMPRESSION);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate reportImpression];
}

/// Tells the delegate that the rewarded ad failed to present.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate didFailToPresentWithError:error];
}

/// Tells the delegate that the rewarded ad was dismissed.
- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
    ADXLogEvent(ADX_PLATFORM_ADMOB, ADX_INVENTORY_RV, ADX_EVENT_CLOSED);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate willDismissFullScreenView];
    [strongDelegate didEndVideo];
    [strongDelegate didDismissFullScreenView];
}

@end
