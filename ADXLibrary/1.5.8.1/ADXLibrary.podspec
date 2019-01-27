Pod::Spec.new do |s|
  s.name = "ADXLibrary"
  s.version = "1.5.8.1"
  s.summary = "ADX Library for iOS"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Chiung Choi"=>"god@adxcorp.kr"}
  s.homepage = "https://github.com/adxcorp/AdxLibrary_iOS"
  s.description = "ADX Library for iOS"
  s.frameworks = ["UIKit", "GLKit", "CoreMotion", "CoreGraphics", "Foundation", "AdSupport", "StoreKit", "QuartzCore", "CoreLocation", "CoreTelephony", "MobileCoreServices", "Accelerate", "AVFoundation", "WebKit", "SystemConfiguration"]
  s.libraries = ["z", "sqlite3", "xml2", "c++"]
  s.source = { :git => 'https://adx-developer:developer2017@github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   =  'ios/ADXLibrary.framework',
                                'ios/FBAudienceNetwork.framework',
                                'ios/GoogleMobileAds.framework',
                                'ios/MTGSDK.framework',
                                'ios/MTGSDKAppWall.framework',
                                'ios/MTGSDKInterstitial.framework',
                                'ios/MTGSDKReward.framework',
                                'ios/ApplinsSDK.framework',
                                'ios/UnityAds.framework',
                                'ios/IronSource.framework',
                                'ios/ZZAdSDK.framework',
                                'ios/ZZDWKit.framework',
                                'ios/AdPieSDK.framework'
  
  s.dependency 'mopub-ios-sdk', '5.4.1'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'OTHER_LDFLAGS' => '-ObjC', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
end
