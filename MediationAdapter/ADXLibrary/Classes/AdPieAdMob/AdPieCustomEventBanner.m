//
//  AdPieCustomEventBanner.m
//  ADXLibrary
//
//  Created by sunny on 2020/08/11.
//

#import "AdPieCustomEventBanner.h"
#import <AdPieSDK/AdPieSDK.h>

#import "ADXLogUtil.h"

@interface AdPieCustomEventBanner () <APAdViewDelegate>

@property (nonatomic, strong) APAdView *adView;

@end

@implementation AdPieCustomEventBanner

@synthesize delegate;

#pragma mark GADCustomEventBanner implementation

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD);
    
    NSDictionary *info = [AdPieCustomEventBanner dictionaryWithJsonString:serverParameter];
    NSString *appId = [info objectForKey:@"app_id"];
    NSString *slotId = [info objectForKey:@"slot_id"];
    
    if (![AdPieSDK sharedInstance].isInitialized) {
        [[AdPieSDK sharedInstance] initWithMediaId:appId];
    }
    
    self.adView = [[APAdView alloc] init];
    self.adView.frame = CGRectMake(0.0, 0.0, adSize.size.width, adSize.size.height);
    self.adView.slotId = slotId;
    self.adView.delegate = self;
    [self.adView load];
}

#pragma mark APAdView delegates

- (void)adViewDidFailToLoadAd:(APAdView *)view withError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, errorMsg);
    
    [self.delegate customEventBanner:self didFailAd:error];
}

- (void)adViewDidLoadAd:(APAdView *)view {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD_SUCCESS);
    
    [self.delegate customEventBanner:self didReceiveAd:self.adView];
}

- (void)adViewWillLeaveApplication:(APAdView *)view {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, ADX_EVENT_CLICK);
    
    [self.delegate customEventBannerWasClicked:self];
    [self.delegate customEventBannerWillLeaveApplication:self];
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

@end
