Pod::Spec.new do |s|
  s.name = "ADXLibrary-Five"
  s.version = "1.5.11"
  s.summary = "ADX Library for iOS"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Chiung Choi"=>"god@adxcorp.kr"}
  s.homepage = "https://github.com/adxcorp/AdxLibrary_iOS"
  s.description = "ADX Library for iOS"
  s.source = { :git => 'https://adx-developer:developer2017@github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target    = '8.0'

  s.frameworks =    'Accelerate',
                    'AdSupport',
                    'AudioToolbox',
                    'AVFoundation',
                    'CFNetwork',
                    'CoreGraphics',
                    'CoreLocation',
                    'CoreMotion',
                    'CoreMedia',
                    'CoreTelephony',
                    'Foundation',
                    'GLKit',
                    'MobileCoreServices',
                    'MediaPlayer',
                    'QuartzCore',
                    'StoreKit',
                    'SystemConfiguration',
                    'UIKit',
                    'VideoToolbox',
                    'WebKit'

  s.ios.vendored_framework   =  'ios/ADXLibrary.framework',
                                'ios/FBAudienceNetwork.framework',
                                'ios/GoogleMobileAds.framework',
                                'ios/MTGSDK.framework',
                                'ios/MTGSDKReward.framework',
                                'ios/UnityAds.framework',
                                'ios/IronSource.framework',
                                'ios/VungleSDK.framework',
                                'ios/PlayableAds.framework',
                                'ios/MATMoatMobileAppKit.framework',
                                'ios/MobFoxSDKCore.framework',
                                'ios/AdPieSDK.framework',
                                'ios/ADXLibrary-Five.framework',
                                'ios/FiveAd.framework'
  
  s.libraries = ["z", "sqlite3", "xml2", "c++"]

  s.resources = "assets/ZplayMuteListener.bundle"
  
  s.dependency 'mopub-ios-sdk', '5.4.1'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'OTHER_LDFLAGS' => '-ObjC', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
end
