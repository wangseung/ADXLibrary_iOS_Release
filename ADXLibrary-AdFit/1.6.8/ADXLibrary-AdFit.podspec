Pod::Spec.new do |s|
  s.name = "ADXLibrary-AdFit"
  s.version = "1.6.8"
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

  s.ios.vendored_framework   =  'ios/ADXLibrary-AdFit.framework'
  
  s.dependency 'mopub-ios-sdk', '5.9.0'
  s.dependency 'AdFitSDK', '3.0.8'

  s.library       = 'z', 'sqlite3', 'xml2', 'c++'

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'OTHER_LDFLAGS' => '-ObjC'}
  s.xcconfig = { 'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES' => 'YES' }
end
