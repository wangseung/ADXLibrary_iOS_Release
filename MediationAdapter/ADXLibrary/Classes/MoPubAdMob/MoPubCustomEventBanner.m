//
//  MoPubCustomEventBanner.m
//  ADXLibrary
//
//  Created by sunny on 2020/08/13.
//

#import "MoPubCustomEventBanner.h"

#import "ADXLogUtil.h"

@interface MoPubCustomEventBanner () <MPAdViewDelegate>

@property (nonatomic) MPAdView *adView;

@end

@implementation MoPubCustomEventBanner

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

- (void)createAndLoad:(NSString *)adUnitId withSize:(GADAdSize)adSize {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.adView = [[MPAdView alloc] initWithAdUnitId:adUnitId];
        self.adView.delegate = self;
        self.adView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        [self.adView loadAdWithMaxAdSize:adSize.size];
    });
}

#pragma mark GADCustomEventBanner implementation

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD);
    
    NSDictionary *info = [MoPubCustomEventBanner dictionaryWithJsonString:serverParameter];
    NSString *adUnitId = [info objectForKey:@"adunit_id"];
    
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:adUnitId];
    
    if(![[MoPub sharedInstance] isSdkInitialized]) {
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig
                                                    completion:^{
            [self createAndLoad:adUnitId withSize:adSize];
                                                    }];
    } else {
        [self createAndLoad:adUnitId withSize:adSize];
    }
}

#pragma mark - MPAdViewDelegate
- (UIViewController *)viewControllerForPresentingModalView {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_BANNER, ADX_EVENT_CLICK);
    
    return [self.adView.window rootViewController];
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD_SUCCESS);
    
    [self.delegate customEventBanner:self didReceiveAd:self.adView];
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_MOPUB, ADX_INVENTORY_BANNER, errorMsg);
    
    [self.delegate customEventBanner:self didFailAd:error];

}

@end
