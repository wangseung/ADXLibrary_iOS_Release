//
//  MoPubCustomEventInterstitial.m
//  ADXLibrary
//
//  Created by sunny on 2020/08/13.
//

#import "MoPubCustomEventInterstitial.h"

#import "ADXLogUtil.h"

@interface MoPubCustomEventInterstitial() <MPInterstitialAdControllerDelegate>
       
@property (nonatomic, retain) MPInterstitialAdController *interstitial;
       
@end

@implementation MoPubCustomEventInterstitial

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

- (void)createAndLoad:(NSString *)adUnitId {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.interstitial = [MPInterstitialAdController
            interstitialAdControllerForAdUnitId:adUnitId];
        self.interstitial.delegate = self;

        [self.interstitial loadAd];
    });
}

#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);
    
    NSDictionary *info = [MoPubCustomEventInterstitial dictionaryWithJsonString:serverParameter];
    NSString *adUnitId = [info objectForKey:@"adunit_id"];
    
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:adUnitId];
    
    if(![[MoPub sharedInstance] isSdkInitialized]) {
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig
                                                    completion:^{
            [self createAndLoad:adUnitId];
        }];
    } else {
        [self createAndLoad:adUnitId];
    }
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.interstitial.ready) {
        [self.interstitial showFromViewController:rootViewController];
    } else {
        // The interstitial wasn't ready, so continue as usual.
    }
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);
    
    [self.delegate customEventInterstitialDidReceiveAd:self];
}
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_FAILURE);
    NSString* errorMsg = @"No Fill";
    NSError *error = [NSError errorWithDomain:kGADErrorDomain
        code:kGADErrorNoFill
    userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
    
    [self.delegate customEventInterstitial:self didFailAd:error];
}
- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    [self.delegate customEventInterstitialWillPresent:self];
}
- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);
}
- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    [self.delegate customEventInterstitialWillDismiss:self];
}
- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);
    
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLICK);
    
    [self.delegate customEventInterstitialWasClicked:self];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

@end
