//
//  CaulyBannerCustomEvent.m
//  ADXLibrary
//
//  Created by sunny on 2021/01/19.
//

#import "CaulyBannerCustomEvent.h"
#import "Cauly.h"
#import "CaulyAdView.h"

#import "ADXLogUtil.h"

@interface CaulyBannerCustomEvent () <CaulyAdViewDelegate>

@property (nonatomic, strong) CaulyAdView *adView;
@property (nonatomic, copy) NSString *appCode;

@end

@implementation CaulyBannerCustomEvent
@dynamic delegate;
@dynamic localExtras;

- (void)dealloc {
    self.adView.delegate = nil;
}

- (NSError *)createErrorWith:(NSString *)descritpion andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(descritpion, nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
    };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

#pragma mark - MPInlineAdAdapter Override

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD);
    
    self.appCode = info[@"app_code"];
    
    if(self.appCode == nil) {
        NSError *error = [self createErrorWith:@"Invalid app code"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    CaulyAdSetting * adSetting = [CaulyAdSetting globalSetting];
    [CaulyAdSetting setLogLevel:CaulyLogLevelAll];
    adSetting.appCode = self.appCode;
    adSetting.animType = CaulyAnimNone;
    
    adSetting.adSize = CaulyAdSize_IPhone;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSetting.adSize = CaulyAdSize_IPadSmall;
    }
    
    adSetting.gender = CaulyGender_All;
    adSetting.age = CaulyAge_All;
    adSetting.reloadTime = CaulyReloadTime_120;
    adSetting.useDynamicReloadTime  = NO;
    adSetting.closeOnLanding = YES;
    
    self.adView = [[CaulyAdView alloc] initWithParentViewController:[self.delegate inlineAdAdapterViewControllerForPresentingModalView:self]];
    self.adView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    self.adView.delegate = self;
    [self.adView startBannerAdRequest];
}

#pragma mark CaulyAdViewDelegate methods

- (void)didReceiveAd:(CaulyAdView *)adView isChargeableAd:(BOOL)isChargeableAd{
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD_SUCCESS);
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.appCode);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.appCode);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.appCode);

    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:adView];
}

- (void)didFailToReceiveAd:(CaulyAdView *)adView errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    NSString *errorMessage = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, errorMsg];
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, errorMessage);
    
    NSError *error = [self createErrorWith:errorMsg
                                 andReason:@""
                             andSuggestion:@""];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);

    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)willShowLandingView:(CaulyAdView *)adView {
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, ADX_EVENT_CLICK);
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.appCode);
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
    
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.appCode);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)didCloseLandingView:(CaulyAdView *)adView {
    
}
@end
