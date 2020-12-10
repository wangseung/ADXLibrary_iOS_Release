//
//  AdPieInterstitialCustomEvent.m
//  ADXLibrary
//
//  Created by 최치웅 on 2018. 12. 21..
//

#import "AdPieInterstitialCustomEvent.h"
#import <AdPieSDK/AdPieSDK.h>

#import "ADXLogUtil.h"

@interface AdPieInterstitialCustomEvent () <APInterstitialDelegate>

@property (nonatomic, strong) APInterstitial *interstitialAd;
@property (nonatomic, copy) NSString *slotId;

@end

@implementation AdPieInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (NSError *)createErrorWith:(NSString *)descritpion andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(descritpion, nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
    };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (void)dealloc {
    self.interstitialAd.delegate = nil;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.interstitialAd && self.interstitialAd.isReady;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);
    
    NSString *appId = info[@"app_id"];
    NSString *slotId = info[@"slot_id"];
    
    if(appId == nil || slotId == nil) {
        NSError *error = [self createErrorWith:@"Invalid app ID or slot ID"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    self.slotId = slotId;
    
    if (![AdPieSDK sharedInstance].isInitialized) {
        [[AdPieSDK sharedInstance] initWithMediaId:appId];
    }
    
    self.interstitialAd = [[APInterstitial alloc] initWithSlotId:slotId];
    self.interstitialAd.delegate = self;
    [self.interstitialAd load];
    
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (self.interstitialAd && self.interstitialAd.isReady) {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.slotId);
        
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.slotId);
        [self.delegate fullscreenAdAdapterAdWillAppear:self];
        
        [self.interstitialAd presentFromRootViewController:viewController];
        
        MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.slotId);
        [self.delegate fullscreenAdAdapterAdDidAppear:self];
        
        ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);
        
    } else {
        NSError *error = [self createErrorWith:@"Error in loading AdPie Interstitial"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.slotId);
        
        [self.delegate fullscreenAdAdapterDidExpire:self];
    }
}

#pragma mark - APInterstitialDelegate

- (void)interstitialDidFailToLoadAd:(APInterstitial *)interstitial withError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, errorMsg);
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);

    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialDidLoadAd:(APInterstitial *)interstitial {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)interstitialWillDismissScreen:(APInterstitial *)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(APInterstitial *)interstitial {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

- (void)interstitialWillLeaveApplication:(APInterstitial *)interstitial {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLICK);
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

@end
