//
//  ADXLogUtil.h
//  ADXLibrary
//
//  Created by sunny on 2020/08/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXLogUtil : NSObject

extern NSString *const kADXPlatformAdColony;
extern NSString *const kADXPlatformAdFit;
extern NSString *const kADXPlatformAdPie;
extern NSString *const kADXPlatformCauly;
extern NSString *const kADXPlatformFacebook;
extern NSString *const kADXPlatformAdMob;
extern NSString *const kADXPlatformIronSource;
extern NSString *const kADXPlatformMoPub;
extern NSString *const kADXPlatformUnityAds;
extern NSString *const kADXPlatformVungle;

extern NSString *const kADXInventroyBanner;
extern NSString *const kADXInventroyInterstitial;
extern NSString *const kADXInventroyNative;
extern NSString *const kADXInventroyRewardedVideo;

extern NSString *const kADXEventLoad;
extern NSString *const kADXEventLoadSuccess;
extern NSString *const kADXEventLoadFailure;
extern NSString *const kADXEventImpression;
extern NSString *const kADXEventClick;
extern NSString *const kADXEventReward;
extern NSString *const kADXEventClosed;

extern void ADXLogEvent(NSString *platform,
                        NSString *inventory,
                        NSString *event);

@end

NS_ASSUME_NONNULL_END
