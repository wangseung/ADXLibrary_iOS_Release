//
//  CaulyCustomEventInterstitial.m
//  ADXLibrary
//
//  Created by sunny on 2021/01/19.
//
//
#import "CaulyCustomEventInterstitial.h"
#import "Cauly.h"
#import "CaulyInterstitialAd.h"

#import "ADXLogUtil.h"

@interface CaulyCustomEventInterstitial () <CaulyInterstitialAdDelegate>

@property (nonatomic, strong) CaulyInterstitialAd *interstitialAd;
@property (nonatomic) BOOL isAdLoaded;

@end

@implementation CaulyCustomEventInterstitial

@synthesize delegate;

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

- (NSError *)createErrorWith:(NSString *)descritpion andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(descritpion, nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
    };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}
#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);
    
    NSDictionary *info = [CaulyCustomEventInterstitial dictionaryWithJsonString:serverParameter];
    NSString *appCode = [info objectForKey:@"app_code"];
    
    self.isAdLoaded = NO;
    
    CaulyAdSetting * adSetting = [CaulyAdSetting globalSetting];
    [CaulyAdSetting setLogLevel:CaulyLogLevelAll];
    adSetting.appCode = appCode;
    
    self.interstitialAd = [[CaulyInterstitialAd alloc] init];
    self.interstitialAd.delegate = self;
    [self.interstitialAd startInterstitialAdRequest];
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.interstitialAd && self.isAdLoaded) {
      [self.delegate customEventInterstitialWillPresent:self];
      [self.interstitialAd showWithParentViewController:rootViewController];
  }
}

#pragma mark - CaulyInterstitialAdDelegate
// 광고 정보 수신 성공
- (void)didReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd isChargeableAd:(BOOL)isChargeableAd {
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);
    
    self.isAdLoaded = YES;
    
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

// 광고 정보 수신 실패
- (void)didFailToReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    NSString *errorMessage = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, errorMsg];
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, errorMessage);
    
    NSError *error = [self createErrorWith:errorMsg
                                 andReason:@""
                             andSuggestion:@""];
    
    [self.delegate customEventInterstitial:self didFailAd:error];
}

// Interstitial 형태의 광고가 보여지기 직전
- (void)willShowInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);
}

// Interstitial 형태의 광고가 닫혔을 때
- (void)didCloseInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    [self.delegate customEventInterstitialWillDismiss:self];
    
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);
    
    [self.delegate customEventInterstitialDidDismiss:self];
}

@end
