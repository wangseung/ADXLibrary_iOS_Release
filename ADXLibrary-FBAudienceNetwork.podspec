Pod::Spec.new do |s|
  s.name = "ADXLibrary-FBAudienceNetwork"
  s.version = "1.7.2"
  s.summary = "ADX Library for iOS"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Chiung Choi"=>"god@adxcorp.kr"}
  s.homepage = "https://github.com/adxcorp/AdxLibrary_iOS"
  s.description = "ADX Library for iOS"
  s.source = { :git => 'https://adx-developer:developer2017@github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target    = '9.0'

  s.frameworks =    'Accelerate',
                    'AdSupport',
                    'AudioToolbox',
                    'AVFoundation',
                    'CFNetwork',
                    'CoreGraphics',
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

  s.ios.vendored_framework   =  'ios/ADXLibrary-FBAudienceNetwork.framework'
  
  s.dependency 'mopub-ios-sdk/Core', '5.9.0'
  s.dependency 'Google-Mobile-Ads-SDK', '7.57.0'
  s.dependency 'IronSourceSDK','6.8.7.0'
  s.dependency 'AdPieSDK','1.2.6'

  s.libraries = ["z", "sqlite3", "xml2", "c++"]
  
  s.default_subspec = 'Default'
  
  ### Begin: Subspecs
  
  s.subspec 'Default' do |ds|
  	ds.dependency 'FBAudienceNetwork','5.9.0'
  end
  
  s.subspec 'Lib' do |ls|
  	ls.dependency 'ADXLibrary-FBAudienceNetwork/Lib-FBAudienceNetwork'
  	ls.dependency 'ADXLibrary-FBAudienceNetwork/Lib-FBSDKCoreKit'
  end
  
  s.subspec 'Lib-FBAudienceNetwork' do |fas|
	fas.ios.vendored_framework =	'ios/ADXLibrary-FBAudienceNetwork.framework',
									'ios/FBAudienceNetwork.framework'
  end
  
  s.subspec 'Lib-FBSDKCoreKit' do |fss|
  	fss.ios.vendored_framework =	'ios/FBSDKCoreKit.framework'
  end
  
  ### End: Subspecs
  
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'OTHER_LDFLAGS' => '-ObjC', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
  s.xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
end
