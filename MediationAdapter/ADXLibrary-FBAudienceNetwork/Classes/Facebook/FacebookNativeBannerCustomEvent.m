//
//  FacebookNativeBannerCustomEvent.m
//  ADXLibrary
//
//  Created by sunny on 2021/01/25.
//
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeBannerCustomEvent.h"
#import "FacebookNativeAdAdapter.h"
#import "FacebookAdapterConfiguration.h"
#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPNativeAd.h"
    #import "MPLogging.h"
    #import "MPNativeAdError.h"
#endif

#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import "ADXLogUtil.h"

static const NSInteger FacebookNoFillErrorCode = 1001;

@interface FacebookNativeBannerCustomEvent () <FBNativeAdDelegate, FBNativeBannerAdDelegate>

@property (nonatomic, readwrite, strong) FBNativeAdBase *fbNativeAdBase;
@property (nonatomic, copy) NSString *fbPlacementId;
@property (nonatomic) MPBool isNativeBanner;

@end

@implementation FacebookNativeBannerCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    [self requestAdWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    ADXLogEvent(ADX_PLATFORM_FACEBOOK, ADX_INVENTORY_NATIVE, ADX_EVENT_LOAD);
    
     self.fbPlacementId = [info objectForKey:@"placement_id"];

    if (self.fbPlacementId) {
        if (self.localExtras != nil && [self.localExtras count] > 0) {
            self.isNativeBanner = [[self.localExtras objectForKey:@"native_banner"] boolValue];
        }
        
        self.isNativeBanner = self.isNativeBanner == MPBoolUnknown ? FacebookAdapterConfiguration.isNativeBanner : self.isNativeBanner;
        
        self.isNativeBanner = MPBoolYes;
        
        if (self.isNativeBanner != MPBoolUnknown) {
            if (self.isNativeBanner) {
                self.fbNativeAdBase = [[FBNativeBannerAd alloc] initWithPlacementID:self.fbPlacementId];
                    ((FBNativeBannerAd *) self.fbNativeAdBase).delegate = self;

                [self loadAdWithMarkup:adMarkup];

                return;
            }
        }
        
        self.fbNativeAdBase = [[FBNativeAd alloc] initWithPlacementID:self.fbPlacementId];
        ((FBNativeAd *) self.fbNativeAdBase).delegate = self;

        [self loadAdWithMarkup:adMarkup];
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"Invalid Facebook placement ID")];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(@"Invalid Facebook placement ID")], self.fbPlacementId);
    }
}

- (void)loadAdWithMarkup:(NSString *)markup
{
    // Load the advanced bid payload.
    if (markup != nil) {
        MPLogInfo(@"Loading Facebook native ad markup for Advanced Bidding");
        [self.fbNativeAdBase loadAdWithBidPayload:markup];

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
    }
    else {
        MPLogInfo(@"Loading Facebook native ad");
        [self.fbNativeAdBase loadAd];

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
    }
    
    [FBAdSettings setMediationService:[FacebookAdapterConfiguration mediationString]];
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    ADXLogEvent(ADX_PLATFORM_FACEBOOK, ADX_INVENTORY_NATIVE, ADX_EVENT_LOAD_SUCCESS);
    
    FacebookNativeAdAdapter *adAdapter = [[FacebookNativeAdAdapter alloc] initWithFBNativeAdBase:nativeAd adProperties:nil];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];

    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_FACEBOOK, ADX_INVENTORY_NATIVE, errorMsg);
    
    if (error.code == FacebookNoFillErrorCode) {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForNoInventory()], self.fbPlacementId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForNoInventory()];
        
    } else {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(@"Facebook ad load error")], self.fbPlacementId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"Facebook ad load error")];
    }
}

#pragma mark - FBNativeBannerAdDelegate

- (void)nativeBannerAdDidLoad:(FBNativeBannerAd *)nativeBannerAd
{
    ADXLogEvent(ADX_PLATFORM_FACEBOOK, ADX_INVENTORY_NATIVE, ADX_EVENT_LOAD_SUCCESS);
    
    FacebookNativeAdAdapter *adAdapter = [[FacebookNativeAdAdapter alloc] initWithFBNativeAdBase:nativeBannerAd adProperties:nil];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)nativeBannerAd:(FBNativeBannerAd *)nativeBannerAd didFailWithError:(NSError *)error
{
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_FACEBOOK, ADX_INVENTORY_NATIVE, errorMsg);
    
    if (error.code == FacebookNoFillErrorCode) {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForNoInventory()], self.fbPlacementId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForNoInventory()];
        
    } else {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(@"Facebook ad load error")], self.fbPlacementId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"Facebook ad load error")];
    }
}

@end
