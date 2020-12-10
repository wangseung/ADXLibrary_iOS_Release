//
//  AdPieBannerCustomEvent.m
//  ADXLibrary
//
//  Created by 최치웅 on 2018. 12. 21..
//

#import "AdPieBannerCustomEvent.h"
#import <AdPieSDK/AdPieSDK.h>

#import "ADXLogUtil.h"

@interface AdPieBannerCustomEvent () <APAdViewDelegate>

@property (nonatomic, strong) APAdView *adView;
@property (nonatomic, copy) NSString *slotId;

@end

@implementation AdPieBannerCustomEvent
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
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD);
    
    NSString *appId = info[@"app_id"];
    NSString *slotId = info[@"slot_id"];
    
    if(appId == nil || slotId == nil) {
        NSError *error = [self createErrorWith:@"Invalid app ID or slot ID"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    self.slotId = slotId;
    
    if (![AdPieSDK sharedInstance].isInitialized) {
        [[AdPieSDK sharedInstance] initWithMediaId:appId];
    }
    
    
    if (!CGSizeEqualToSize(size, CGSizeMake(320, 50)) && !CGSizeEqualToSize(size, CGSizeMake(300, 250))) {
        NSError *error = [self createErrorWith:@"Invalid size for AdPie banner"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![AdPieSDK sharedInstance].isInitialized) {
        [[AdPieSDK sharedInstance] initWithMediaId:appId];
    }
    
    self.adView = [[APAdView alloc] init];
    self.adView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    self.adView.slotId = slotId;
    self.adView.delegate = self;
    [self.adView load];
}

#pragma mark APAdViewDelegate methods

- (void)adViewDidFailToLoadAd:(APAdView *)view withError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, errorMsg);
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);

    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)adViewDidLoadAd:(APAdView *)view {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, ADX_EVENT_LOAD_SUCCESS);
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.slotId);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.slotId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.slotId);

    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:view];
}

- (void)adViewWillLeaveApplication:(APAdView *)view {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_BANNER, ADX_EVENT_CLICK);
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
    
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}
@end
