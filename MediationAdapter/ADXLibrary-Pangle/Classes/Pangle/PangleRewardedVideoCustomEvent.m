#import "PangleRewardedVideoCustomEvent.h"
    #import <BUAdSDK/BUAdSDK.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPRewardedVideoError.h"
    #import "MPReward.h"
#endif
#import "PangleAdapterConfiguration.h"

#import "ADXLogUtil.h"

@interface PangleRewardedVideoCustomEvent () <BURewardedVideoAdDelegate>
@property (nonatomic, strong) BURewardedVideoAd *rewardVideoAd;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;
@end

@implementation PangleRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.rewardVideoAd.isAdValid;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_LOAD);
    
    BOOL hasAdMarkup = adMarkup.length > 0;
    
    if (info.count == 0) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Incorrect or missing Pangle App ID or Placement ID on the network UI. Ensure the App ID and Placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }
    
    self.appId = [info objectForKey:kPangleAppIdKey];
    if (BUCheckValidString(self.appId)) {
        [PangleAdapterConfiguration pangleSDKInitWithAppId:self.appId];
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    
    self.adPlacementId = [info objectForKey:kPanglePlacementIdKey];
    if (!BUCheckValidString(self.adPlacementId)) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey: @"Incorrect or missing Pangle placement ID. Failing ad request. Ensure the ad placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = self.adPlacementId;
    
    if (BUCheckValidString([PangleAdapterConfiguration userId])) {
        model.userId = [PangleAdapterConfiguration userId];
    }
    if (BUCheckValidString([PangleAdapterConfiguration rewardName])) {
        model.rewardName = [PangleAdapterConfiguration rewardName];
    }
    if ([PangleAdapterConfiguration rewardAmount] != 0) {
        model.rewardAmount = [PangleAdapterConfiguration rewardAmount];
    }
    if (BUCheckValidString([PangleAdapterConfiguration mediaExtra])) {
        model.extra = [PangleAdapterConfiguration mediaExtra];
    }
    
    BURewardedVideoAd *RewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.adPlacementId rewardedVideoModel:model];
    RewardedVideoAd.delegate = self;
    self.rewardVideoAd = RewardedVideoAd;
    
    if (hasAdMarkup) {
        MPLogInfo(@"Loading Pangle rewarded video ad markup for Advanced Bidding");

        [RewardedVideoAd setMopubAdMarkUp:adMarkup];
    } else {
        MPLogInfo(@"Loading Pangle rewarded video ad");
        
        [RewardedVideoAd loadAdData];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}
    
- (void)presentAdFromViewController:(UIViewController *)viewController {
    if ([self hasAdAvailable]) {
        [self.rewardVideoAd showAdFromRootViewController:viewController];
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    } else {
        NSError *error = [NSError
                          errorWithDomain:MoPubRewardedVideoAdsSDKDomain
                          code:BUErrorCodeNERenderResultError
                          userInfo:@{NSLocalizedDescriptionKey : @"Failed to show Pangle rewarded video."}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

#pragma mark BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_LOAD_SUCCESS);
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, errorMsg);
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_IMPRESSION);
    
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_CLOSED);
    
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_CLICK);
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if (error != nil) {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    } else {
        MPLogInfo(@"Rewarded video finished playing");
    }
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    if (verify) {
        ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_RV, ADX_EVENT_REWARD);
        
        NSString *currencyType = BUCheckValidString(rewardedVideoAd.rewardedVideoModel.rewardName) ? rewardedVideoAd.rewardedVideoModel.rewardName :kMPRewardCurrencyTypeUnspecified;
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyType amount: @(rewardedVideoAd.rewardedVideoModel.rewardAmount)];
        
        MPLogEvent([MPLogEvent adShouldRewardUserWithReward:reward]);
        
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    } else {
        MPLogInfo(@"Rewarded video ad failed to verify.");
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
    MPLogInfo(@"Rewarded video ad server failed to reward: %@", error);
}

- (NSString *) getAdNetworkId {
    return (BUCheckValidString(self.adPlacementId)) ? self.adPlacementId : @"";
}

@end