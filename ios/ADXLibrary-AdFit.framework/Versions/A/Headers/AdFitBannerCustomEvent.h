//
//  AdFitBannerCustomEvent.h
//  ADXLibrary
//
//  Created by 최치웅 on 2019. 4. 30..
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPBannerCustomEvent.h"
#import "MPLogging.h"
#endif

@interface AdFitBannerCustomEvent : MPBannerCustomEvent

@end
