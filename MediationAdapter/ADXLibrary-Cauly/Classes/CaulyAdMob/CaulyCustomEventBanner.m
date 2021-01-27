//
//  CaulyCustomEventBanner.m
//  ADXLibrary
//
//  Created by sunny on 2021/01/19.
//
//
#import "CaulyCustomEventBanner.h"
#import "Cauly.h"
#import "CaulyAdView.h"

#import "ADXLogUtil.h"

@interface CaulyCustomEventBanner () <CaulyAdViewDelegate>

@property (nonatomic, strong) CaulyAdView *adView;

@end

@implementation CaulyCustomEventBanner

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

#pragma mark GADCustomEventBanner implementation

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD);
    
    NSDictionary *info = [CaulyCustomEventBanner dictionaryWithJsonString:serverParameter];
    NSString *appCode = [info objectForKey:@"app_code"];
    
    CaulyAdSetting * adSetting = [CaulyAdSetting globalSetting];
    [CaulyAdSetting setLogLevel:CaulyLogLevelAll];
    adSetting.appCode = appCode;
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
    
    self.adView = [[CaulyAdView alloc] init];
    self.adView.frame = CGRectMake(0.0, 0.0, adSize.size.width, adSize.size.height);
    self.adView.delegate = self;
    [self.adView startBannerAdRequest];
}

#pragma mark CaulyAdViewDelegate methods

- (void)didReceiveAd:(CaulyAdView *)adView isChargeableAd:(BOOL)isChargeableAd{
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD_SUCCESS);
    
    [adView showWithParentViewController:[adView.window rootViewController] target:adView];
    
    [self.delegate customEventBanner:self didReceiveAd:self.adView];
}

- (void)didFailToReceiveAd:(CaulyAdView *)adView errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    NSString *errorMessage = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, errorMsg];
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, errorMessage);
    
    NSError *error = [self createErrorWith:errorMsg
                                 andReason:@""
                             andSuggestion:@""];
    
    [self.delegate customEventBanner:self didFailAd:error];
}

- (void)willShowLandingView:(CaulyAdView *)adView {
    ADXLogEvent(ADX_PLATFORM_CAULY, ADX_INVENTORY_BANNER, ADX_EVENT_CLICK);
    
    [self.delegate customEventBannerWasClicked:self];
    [self.delegate customEventBannerWillLeaveApplication:self];
}

- (void)didCloseLandingView:(CaulyAdView *)adView {
    
}

@end
