Pod::Spec.new do |s|
  s.name = "ADXLibrary-Cauly"
  s.version = "1.8.5"
  s.summary = "ADX Library for iOS"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Chiung Choi"=>"god@adxcorp.kr"}
  s.homepage = "https://github.com/adxcorp/AdxLibrary_iOS"
  s.description = "ADX Library for iOS"
  s.source = { :git => 'https://github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target    = '10.0'
  
  s.source_files = 'MediationAdapter/ADXLibrary-Cauly/Classes/**/*'
  #s.resources = ["MediationAdapter/ADXLibrary-Cauly/Assets/*"]

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
  
  s.dependency 'mopub-ios-sdk', '5.15.0'
  s.dependency 'Google-Mobile-Ads-SDK', '7.69.0'
  s.static_framework = true
  s.ios.vendored_libraries = 'MediationAdapter/ADXLibrary-Cauly/Lib/libCauly-universal.a'

  s.library       = 'z', 'sqlite3', 'xml2', 'c++'

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'OTHER_LDFLAGS' => '-ObjC', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
