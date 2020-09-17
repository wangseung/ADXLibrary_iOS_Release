//
//  ADXGDPR.h
//  ADXLibrary
//
//  Created by Eleanor Choi on 2018. 5. 28..
//

#import <Foundation/Foundation.h>
#import <ADXLibrary-Core/ADXGdprBase.h>

#define ADX_SDK_VERSION @"1.8.0"

@interface ADXGDPR : ADXGdprBase

/**
 get instance

 @return ADXGDPR instance
 */
+ (ADXGDPR *)sharedInstance;

@end
