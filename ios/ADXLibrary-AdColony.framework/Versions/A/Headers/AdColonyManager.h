//
//  AdColonyManager.h
//  ADXLibrary-AdColony
//
//  Created by sunny on 2019/11/07.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AdColonyManager : NSObject

+ (instancetype _Nonnull)sharedManager;

- (void)initializeWithAppId:(NSString *_Nonnull)appID zoneIDs:(NSArray<NSString *> *_Nonnull)zoneID completion:(void(^_Nullable)(void))completionBlock;

- (void)setRewardDelegate:(id<GADMediationRewardedAdEventDelegate>_Nullable) delagate;

@end
