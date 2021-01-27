//
//  PangleCustomEventInterstitial.m
//  ADXLibrary
//
//  Created by sunny on 2021/01/22.
//

#import "PangleCustomEventInterstitial.h"

#import <ADXLibrary/ADXGDPR.h>
#import "ADXLogUtil.h"

@interface PangleCustomEventInterstitial () <BUFullscreenVideoAdDelegate>

@property (nonatomic, strong) BUFullscreenVideoAd *fullScreenVideo;
@end

@implementation PangleCustomEventInterstitial

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

#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);
    
    NSDictionary *info = [PangleCustomEventInterstitial dictionaryWithJsonString:serverParameter];
    NSString *appId = [info objectForKey:@"app_id"];
    NSString *adPlacementId = [info objectForKey:@"ad_placement_id"];
    
    if ([ADXGDPR.sharedInstance getConsentState] == ADXConsentStateDenied) {
        [BUAdSDKManager setGDPR:1];
    } else {
        [BUAdSDKManager setGDPR:0];
    }
    
    [BUAdSDKManager setAppID:appId];
    
    self.fullScreenVideo = [[BUFullscreenVideoAd alloc] initWithSlotID:adPlacementId];
    self.fullScreenVideo.delegate = self;
    
    [self.fullScreenVideo loadAdData];
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (!self.fullScreenVideo || !self.fullScreenVideo.adValid) {
    } else {
        [self.fullScreenVideo showAdFromRootViewController:rootViewController ritSceneDescribe:nil];
    }
}

#pragma mark - BUFullscreenVideoAdDelegate - Full Screen Video

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);
    
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    // no-op
}

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
}

- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd{
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);
    
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)fullscreenVideoAdWillClose:(BUFullscreenVideoAd *)fullscreenVideoAd{
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);
    
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLICK);
    
    [self.delegate customEventInterstitialWasClicked:self];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_PANGLE, ADX_INVENTORY_INTERSTITIAL, errorMsg);
    
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
}

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {

}

@end
