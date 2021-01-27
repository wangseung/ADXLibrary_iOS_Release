//
//  NativeAdFactory.m
//  Pods
//
//  Created by 최치웅 on 2017. 3. 17..
//
//

#import "NativeAdFactory.h"
#import "MPGoogleAdMobNativeRenderer.h"

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MoPub.h"
#endif

@implementation NativeAdFactory

+ (id)sharedInstance {
    static NativeAdFactory *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _nativeAds = [[NSMutableDictionary alloc] init];
        _renderingViewClasses = [[NSMutableDictionary alloc] init];
        _viewSizeHandlers = [[NSMutableDictionary alloc] init];
        _loadings = [[NSMutableDictionary alloc] init];
        _preloadings = [[NSMutableDictionary alloc] init];
        _delegateSet = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)addDelegate:(id)delegate {
    if ([_delegateSet containsObject:delegate]) {
        return;
    }
    
    [_delegateSet addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
    if ([_delegateSet containsObject:delegate]) {
        [_delegateSet removeObject:delegate];
    }
}

- (void)fireOnSuccess:(NSString *)adUnitId nativeAd:(MPNativeAd *)nativeAd {
    @try {
        for (id<NativeAdFactoryDelegate> delegate in _delegateSet) {
            [delegate onSuccess:adUnitId nativeAd:nativeAd];
        }
    } @catch (NSException *exception) {
    }
}

- (void)fireOnFailure:(NSString *)adUnitId {
    @try {
        for (id<NativeAdFactoryDelegate> delegate in _delegateSet) {
            [delegate onFailure:adUnitId];
        }
    } @catch (NSException *exception) {
    }
}

- (void)setIsLoading:(NSString *)adUnitId isLoading:(BOOL)isLoading {
    [_loadings setObject:[NSNumber numberWithBool:isLoading] forKey:adUnitId];
}

- (BOOL)isLoading:(NSString *)adUnitId {
    NSNumber * number = [_loadings objectForKey:adUnitId];
    
    if(number == nil || [number boolValue] == NO) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setIsPreloading:(NSString *)adUnitId isLoading:(BOOL)isPreloading {
    [_preloadings setObject:[NSNumber numberWithBool:isPreloading] forKey:adUnitId];
}

- (BOOL)isPreloading:(NSString *)adUnitId {
    NSNumber * number = [_preloadings objectForKey:adUnitId];
    
    if(number == nil || [number boolValue] == NO) {
        return NO;
    } else {
        return YES;
    }
}

- (void)preloadAd:(NSString *)adUnitId {
    if([_nativeAds objectForKey:adUnitId] != nil) {
        return;
    }
    
    if([self isPreloading:adUnitId]) {
        return;
    }
    
    [self setIsPreloading:adUnitId isLoading:YES];
    
    Class renderingViewClass = [self getRenderingViewClass:adUnitId];
    
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    settings.renderingViewClass = renderingViewClass;
    
    MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
    config.supportedCustomEvents = @[@"MPMoPubNativeCustomEvent", @"FacebookNativeCustomEvent", @"FacebookNativeBannerCustomEvent",
                                     @"MobvistaNativeCustomEvent", @"MobFoxMoPubNativeCustomEvent", @"AdPieNativeCustomEvent", @"PangleNativeCustomEvent"];
    
    MPNativeAdRendererConfiguration *googleConfiguration = [MPGoogleAdMobNativeRenderer rendererConfigurationWithRendererSettings:settings];
    
    MPNativeAdRequest *adRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:adUnitId rendererConfigurations:@[config, googleConfiguration]];
    
    __weak NativeAdFactory *weakSelf = self;
    
    [adRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        [weakSelf setIsPreloading:adUnitId isLoading:NO];
        
        if (error == nil) {
            [weakSelf.nativeAds setObject:response forKey:adUnitId];
            
            if([weakSelf isLoading:adUnitId]) {
                [weakSelf setIsLoading:adUnitId isLoading:NO];
                [weakSelf fireOnSuccess:adUnitId nativeAd:response];
            }
        } else {
            if([weakSelf isLoading:adUnitId]) {
                [weakSelf setIsLoading:adUnitId isLoading:NO];
                [weakSelf fireOnFailure:adUnitId];
            }
        }
    }];
}

- (void)loadAd:(NSString *)adUnitId {
    if([_nativeAds objectForKey:adUnitId] != nil) {
        [self fireOnSuccess:adUnitId nativeAd:[_nativeAds objectForKey:adUnitId]];
        return;
    }
    
    if([self isLoading:adUnitId]) {
        return;
    }
    
    [self setIsLoading:adUnitId isLoading:YES];
    [self preloadAd:adUnitId];
}

- (MPTableViewAdPlacer *)getTableViewAdPlacer:(NSString *)adUnitId tableView:(UITableView *)tableView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler {
    return [self getTableViewAdPlacer:adUnitId tableView:tableView viewController:viewController viewSizeHandler:viewSizeHandler adPositioning:[MPServerAdPositioning positioning]];
}

- (MPTableViewAdPlacer *)getTableViewAdPlacer:(NSString *)adUnitId tableView:(UITableView *)tableView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler adPositioning:(MPAdPositioning *)adPositioning {
    Class renderingViewClass = [self getRenderingViewClass:adUnitId];
    
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    settings.renderingViewClass = renderingViewClass;
    settings.viewSizeHandler = viewSizeHandler;
    
    MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
    config.supportedCustomEvents = @[@"MPMoPubNativeCustomEvent", @"FacebookNativeCustomEvent", @"FacebookNativeBannerCustomEvent",
                                     @"MobvistaNativeCustomEvent", @"MobFoxMoPubNativeCustomEvent", @"AdPieNativeCustomEvent", @"PangleNativeCustomEvent"];
    
    MPNativeAdRendererConfiguration *googleConfiguration = [MPGoogleAdMobNativeRenderer rendererConfigurationWithRendererSettings:settings];
    
    MPTableViewAdPlacer * placer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:viewController adPositioning:adPositioning rendererConfigurations:@[config, googleConfiguration]];
    
    return placer;
}

- (MPCollectionViewAdPlacer *)getCollectionViewAdPlacer:(NSString *)adUnitId collectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler {
    return [self getCollectionViewAdPlacer:adUnitId collectionView:collectionView viewController:viewController viewSizeHandler:viewSizeHandler adPositioning:[MPServerAdPositioning positioning]];
}

- (MPCollectionViewAdPlacer *)getCollectionViewAdPlacer:(NSString *)adUnitId collectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler adPositioning:(MPAdPositioning *)adPositioning {
    
    Class renderingViewClass = [self getRenderingViewClass:adUnitId];
    
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    settings.renderingViewClass = renderingViewClass;
    settings.viewSizeHandler = viewSizeHandler;
    
    MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
    config.supportedCustomEvents = @[@"MPMoPubNativeCustomEvent", @"FacebookNativeCustomEvent", @"FacebookNativeBannerCustomEvent",
                                     @"MobvistaNativeCustomEvent", @"MobFoxMoPubNativeCustomEvent", @"AdPieNativeCustomEvent", @"PangleNativeCustomEvent"];
    
    MPNativeAdRendererConfiguration *googleConfiguration = [MPGoogleAdMobNativeRenderer rendererConfigurationWithRendererSettings:settings];
    
    MPCollectionViewAdPlacer * placer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:viewController adPositioning:adPositioning rendererConfigurations:@[config, googleConfiguration]];
    
    return placer;
}

- (MPNativeAd *)getNativeAd:(NSString *)adUnitId {
    if (adUnitId == nil || adUnitId.length == 0) {
        return nil;
    }
    
    return [_nativeAds objectForKey:adUnitId];
}

- (void)setRenderingViewClass:(NSString *)adUnitId renderingViewClass:(Class)renderingViewClass {
    [_renderingViewClasses setObject:renderingViewClass forKey:adUnitId];
}

- (Class)getRenderingViewClass:(NSString *)adUnitId {
    return [_renderingViewClasses objectForKey:adUnitId];
}

- (UIView *)getNativeAdView:(NSString *)adUnitId {
    MPNativeAd * nativeAd = [self getNativeAd:adUnitId];
    
    if(nativeAd == nil) {
        return nil;
    }
    
    UIView * view = [nativeAd retrieveAdViewWithError:nil];
    
    [_nativeAds removeObjectForKey:adUnitId];
    [self preloadAd:adUnitId];
    
    return view;
}

@end
