//
//  FiveRewardedVideoCustomEvent.h
//  ADXLibrary
//
//  Created by 최치웅 on 2018. 12. 17..
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPRewardedVideoReward.h"
    #import "MPRewardedVideoCustomEvent.h"
#endif

@interface FiveRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

@end
