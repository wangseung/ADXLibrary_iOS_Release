//
//  PangleCustomEventRewardedVideo.m
//  ADXLibrary
//
//  Created by sunny on 2021. 1. 22..
//

#import "PangleCustomEventRewardedVideo.h"

#import "ADXLogUtil.h"

@interface PangleCustomEventRewardedVideo() <BURewardedVideoAdDelegate> {
    GADMediationRewardedLoadCompletionHandler _adLoadCompletionHandler;
    __weak id<GADMediationRewardedAdEventDelegate> _adEventDelegate;
}

@property(nonatomic, copy) NSString *adUnitId;
@property (nonatomic, strong) BURewardedVideoAd *rewardVideoAd;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;

@end

@implementation PangleCustomEventRewardedVideo

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
  NSString *versionString = [BUAdSDKManager SDKVersion];
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
  return [PangleCustomEventRewardedVideo adapterVersion];
}

+ (GADVersionNumber)adapterVersion {
  NSArray *versionComponents = [@"3.3.6.2" componentsSeparatedByString:@"."];
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
    NSDictionary *info = [PangleCustomEventRewardedVideo dictionaryWithJsonString:parameter];
    NSString *appId = [info objectForKey:@"app_id"];
    
    NSString *errorMsg = nil;
    if (!BUCheckValidString(appId)) errorMsg = @"Incorrect or missing Pangle appId. Failing to initialize. Ensure the appId is correct.";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kGADErrorDomain
                                             code:kGADErrorInvalidArgument
                                         userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        completionHandler(error);
        return;
    }
    
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
    
    [BUAdSDKManager setAppID:appId];
    
    completionHandler(nil);
}
                                  
- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_LOAD);
    
    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *info = [PangleCustomEventRewardedVideo dictionaryWithJsonString:parameter];
    NSString *appId = [info objectForKey:@"app_id"];
    NSString *adPlacementId = [info objectForKey:@"ad_placement_id"];
    
    self.appId = appId;
    self.adPlacementId = adPlacementId;
    
    [BUAdSDKManager setAppID:appId];
    
    _adLoadCompletionHandler = completionHandler;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
        model.userId = self.adPlacementId;
        
        BURewardedVideoAd *RewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.adPlacementId rewardedVideoModel:model];
        RewardedVideoAd.delegate = self;
        self.rewardVideoAd = RewardedVideoAd;
        
        [RewardedVideoAd loadAdData];
    });
}

#pragma mark GADMediationRewardedAd implementation

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    
    if (self.rewardVideoAd.isAdValid) {
        [self.rewardVideoAd showAdFromRootViewController:viewController];
    } else {
        NSLog(@"Pangle rewarded video ad was not available");
        NSError *error = [NSError errorWithDomain:kGADErrorDomain code:kGADErrorInternalError userInfo:nil];
        [_adEventDelegate didFailToPresentWithError:error];
    }
}

#pragma mark BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_LOAD_SUCCESS);

    _adEventDelegate = _adLoadCompletionHandler((id) self, nil);
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, errorMsg);

    _adLoadCompletionHandler(nil, error);
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_IMPRESSION);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate reportImpression];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate willDismissFullScreenView];
    
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_CLOSED);

    [strongDelegate didEndVideo];
    [strongDelegate didDismissFullScreenView];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_CLICK);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
    [strongDelegate reportClick];
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if (error != nil) {
        id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
        [strongDelegate didFailToPresentWithError:error];
    } else {
        NSLog(@"Rewarded video finished playing");
    }
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    if (verify) {
        ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_REWARD);

        id<GADMediationRewardedAdEventDelegate> strongDelegate = _adEventDelegate;
        [strongDelegate didRewardUserWithReward:[[GADAdReward alloc] initWithRewardType:@"" rewardAmount:[NSDecimalNumber one]]];
    } else {
        NSLog(@"Rewarded video ad failed to verify.");
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
    NSLog(@"Rewarded video ad server failed to reward: %@", error);
}

@end
