//
//  CaulyInterstitialCustomEvent.m
//  ADXLibrary
//
//  Created by sunny on 2021/01/19.
//

#import "CaulyInterstitialCustomEvent.h"
#import "Cauly.h"
#import "CaulyInterstitialAd.h"

#import "ADXLogUtil.h"

@interface CaulyInterstitialCustomEvent () <CaulyInterstitialAdDelegate>

@property (nonatomic, strong) CaulyInterstitialAd *interstitialAd;
@property (nonatomic, copy) NSString *appCode;
@property (nonatomic) BOOL isAdLoaded;

@end

@implementation CaulyInterstitialCustomEvent
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
    return self.interstitialAd && self.isAdLoaded;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);
    
    self.appCode = info[@"app_code"];
    
    if(self.appCode == nil) {
        NSError *error = [self createErrorWith:@"Invalid app code"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    self.isAdLoaded = NO;
    
    CaulyAdSetting * adSetting = [CaulyAdSetting globalSetting];
    [CaulyAdSetting setLogLevel:CaulyLogLevelAll];
    adSetting.appCode = self.appCode;
    
    self.interstitialAd = [[CaulyInterstitialAd alloc] init];
    self.interstitialAd.delegate = self;
    [self.interstitialAd startInterstitialAdRequest];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (self.interstitialAd && self.isAdLoaded) {
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.appCode);
        
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.appCode);
        [self.delegate fullscreenAdAdapterAdWillAppear:self];
        
        [self.interstitialAd showWithParentViewController:viewController];
        
        MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.appCode);
        [self.delegate fullscreenAdAdapterAdDidAppear:self];
        
    } else {
        NSError *error = [self createErrorWith:@"Error in loading Cauly Interstitial"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.appCode);
        
        [self.delegate fullscreenAdAdapterDidExpire:self];
    }
}

#pragma mark - CaulyInterstitialAdDelegate
// 광고 정보 수신 성공
- (void)didReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd isChargeableAd:(BOOL)isChargeableAd {
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);
    
    self.isAdLoaded = YES;
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.appCode);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

// 광고 정보 수신 실패
- (void)didFailToReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    NSString *errorMessage = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, errorMsg];
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, errorMessage);
    
    NSError *error = [self createErrorWith:errorMsg
                                 andReason:@""
                             andSuggestion:@""];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);

    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

// Interstitial 형태의 광고가 보여지기 직전
- (void)willShowInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);
}

// Interstitial 형태의 광고가 닫혔을 때
- (void)didCloseInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.appCode);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.appCode);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

@end
