//
//  AdPieNativeAdAdapter.m
//  ADXLibrary
//
//  Created by 최치웅 on 12/08/2019.
//

#import "AdPieNativeAdAdapter.h"
#import <AdPieSDK/AdPieSDK.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPNativeAdConstants.h"
    #import "MPNativeAdError.h"

#endif

#import "ADXLogUtil.h"

@implementation AdPieNativeAdAdapter

@synthesize nativeAd = _nativeAd;
@synthesize properties = _properties;
@synthesize defaultActionURL = _defaultActionURL;
@synthesize destinationDisplayAgent = _destinationDisplayAgent;

- (instancetype)initWithNativeAd:(APNativeAd *)nativeAd {
    if (self = [super init]) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
        if(nativeAd.nativeAdData.title){
            properties[kAdTitleKey] = nativeAd.nativeAdData.title;
        }
        
        if(nativeAd.nativeAdData.desc){
            properties[kAdTextKey] = nativeAd.nativeAdData.desc;
        }
        
        if(nativeAd.nativeAdData.callToAction){
            properties[kAdCTATextKey] = nativeAd.nativeAdData.callToAction;
        }
        
        if(nativeAd.nativeAdData.rating){
            properties[kAdStarRatingKey] = [NSNumber numberWithDouble:nativeAd.nativeAdData.rating];
        }
        
        if(nativeAd.nativeAdData.mainImageUrl){
            properties[kAdMainImageKey] = nativeAd.nativeAdData.mainImageUrl;
        }
        
        if(nativeAd.nativeAdData.iconImageUrl){
            properties[kAdIconImageKey] = nativeAd.nativeAdData.iconImageUrl;
        }
        
        if(nativeAd.nativeAdData.optoutImageUrl){
            properties[kAdPrivacyIconImageUrlKey] = nativeAd.nativeAdData.optoutImageUrl;
        }
        
        if (nativeAd.nativeAdData.optoutLink) {
            properties[kAdPrivacyIconClickUrlKey] = nativeAd.nativeAdData.optoutLink;
        }
        
        self.nativeAd = nativeAd;
        self.properties = properties;
        
        self.impressionTimer = [[MPAdImpressionTimer alloc] initWithRequiredSecondsForImpression:0.0 requiredViewVisibilityPercentage:0.5];
        self.impressionTimer.delegate = self;
        
        self.destinationDisplayAgent = [MPAdDestinationDisplayAgent agentWithDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [_destinationDisplayAgent cancel];
    [_destinationDisplayAgent setDelegate:nil];
}

- (NSURL *)defaultActionURL {
    return nil;
}

#pragma mark - Click tracking
- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_NATIVE, ADX_EVENT_CLICK);
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], nil);
    
    // 클릭 트래킹 처리
    [self.nativeAd invokeDefaultAction];
    [self.delegate nativeAdDidClick:self];
}

#pragma mark - Impression tracking
- (void)willAttachToView:(UIView *)view {
    [self.impressionTimer startTrackingView:view];
}

- (void)adViewWillLogImpression:(UIView *)adView {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_NATIVE, ADX_EVENT_IMPRESSION);
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], nil);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], nil);
    
    // 임프레션 트래킹 처리
    [self.nativeAd fireImpression];
    [self.delegate nativeAdWillLogImpression:self];
}

#pragma mark - Privacy Icon
- (void)displayContentForDAAIconTap
{
    NSURL *defaultPrivacyClickUrl = [NSURL URLWithString:kPrivacyIconTapDestinationURL];
    NSURL *overridePrivacyClickUrl = ({
        NSString *url = self.properties[kAdPrivacyIconClickUrlKey];
        (url != nil ? [NSURL URLWithString:url] : nil);
    });
    
    [self.destinationDisplayAgent displayDestinationForURL:(overridePrivacyClickUrl != nil ? overridePrivacyClickUrl : defaultPrivacyClickUrl) skAdNetworkClickthroughData:nil];
}

#pragma mark - <MPAdDestinationDisplayAgentDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal
{
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)displayAgentWillLeaveApplication
{
    [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
}

- (void)displayAgentDidDismissModal
{
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

@end
