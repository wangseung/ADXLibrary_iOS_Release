//
//  AdPieNativeCustomEvent.m
//  ADXLibrary
//
//  Created by 최치웅 on 12/08/2019.
//

#import "AdPieNativeCustomEvent.h"
#import "AdPieNativeAdAdapter.h"
#import <AdPieSDK/AdPieSDK.h>

#if __has_include("MoPub.h")
    #import "MPNativeAd.h"
    #import "MPLogging.h"
    #import "MPNativeAdError.h"
#endif

#import "ADXLogUtil.h"

@interface AdPieNativeCustomEvent() <APNativeDelegate>

@property (nonatomic, strong) APNativeAd * nativeAd;
@property (nonatomic, copy) NSString *slotId;

@end

@implementation AdPieNativeCustomEvent

- (NSError *)createErrorWith:(NSString *)descritpion andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(descritpion, nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
    };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

-(void)loadNativeAdWithSlotId:(NSString *)slotId {
    self.nativeAd = [[APNativeAd alloc] initWithSlotId:slotId];
    self.nativeAd.delegate = self;
    [self.nativeAd load];
}

#pragma mark - MPNativeCustomEvent Override

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_NATIVE, ADX_EVENT_LOAD);
    
    NSString *appId = info[@"app_id"];
    NSString *slotId = info[@"slot_id"];
    
    if(appId == nil || slotId == nil) {
        NSError *error = [self createErrorWith:@"Invalid app ID or slot ID"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    self.slotId = slotId;
    
    if(![[AdPieSDK sharedInstance] isInitialized]) {
        [[AdPieSDK sharedInstance] initWithMediaId:appId completion:^(BOOL isInitialized) {
            MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.slotId);
            
            [self loadNativeAdWithSlotId:slotId];
        }];
    } else {
        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.slotId);
        
        [self loadNativeAdWithSlotId:slotId];
    }
}

#pragma mark APNativeDelegate methods

// 네이티브 성공
- (void)nativeDidLoadAd:(APNativeAd *)nativeAd {
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_NATIVE, ADX_EVENT_LOAD_SUCCESS);
    
    AdPieNativeAdAdapter *adAdapter = [[AdPieNativeAdAdapter alloc] initWithNativeAd:nativeAd];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.slotId);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

// 네이티브 실패
- (void)nativeDidFailToLoadAd:(APNativeAd *)nativeAd withError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_ADPIE, ADX_INVENTORY_NATIVE, errorMsg);
    
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.slotId);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForNoInventory()];
}

// 네이티브 클릭 알림
- (void)nativeWillLeaveApplication:(APNativeAd *)nativeAd {
}

@end
