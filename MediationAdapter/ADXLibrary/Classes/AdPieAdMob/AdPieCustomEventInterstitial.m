//
//  AdPieCustomEventInterstitial.m
//  ADXLibrary
//
//  Created by sunny on 2020/08/11.
//

#import "AdPieCustomEventInterstitial.h"
#import <AdPieSDK/AdPieSDK.h>

#import "ADXLogUtil.h"

@interface AdPieCustomEventInterstitial () <APInterstitialDelegate>

@property (nonatomic, strong) APInterstitial *interstitialAd;
@end

@implementation AdPieCustomEventInterstitial

@synthesize delegate;

#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);
    
    NSDictionary *info = [AdPieCustomEventInterstitial dictionaryWithJsonString:serverParameter];
    NSString *appId = [info objectForKey:@"app_id"];
    NSString *slotId = [info objectForKey:@"slot_id"];
    
    if (![AdPieSDK sharedInstance].isInitialized) {
        [[AdPieSDK sharedInstance] initWithMediaId:appId];
    }
    
    self.interstitialAd = [[APInterstitial alloc] initWithSlotId:slotId];
    self.interstitialAd.delegate = self;
    [self.interstitialAd load];
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.interstitialAd && self.interstitialAd.isReady) {
      ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);
      
      [self.delegate customEventInterstitialWillPresent:self];
      [self.interstitialAd presentFromRootViewController:rootViewController];
  }
}

#pragma mark APInterstitial delegates

- (void)interstitialDidFailToLoadAd:(APInterstitial *)interstitial withError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, errorMsg);
    
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)interstitialDidLoadAd:(APInterstitial *)interstitial {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);
    
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)interstitialWillDismissScreen:(APInterstitial *)interstitial {
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)interstitialDidDismissScreen:(APInterstitial *)interstitial {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);
    
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)interstitialWillLeaveApplication:(APInterstitial *)interstitial {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLICK);
    
    [self.delegate customEventInterstitialWasClicked:self];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
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
