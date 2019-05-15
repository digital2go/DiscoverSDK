Pod::Spec.new do |s|

  s.name         = "DiscoverSDK"
  s.version      = "0.5.4"
  s.license      = "MIT"
  s.summary      = "A framework that provides device information and data collecting"
  s.homepage     = "https://locally.io/"
  s.author       = { "Eduardo Dias" => "eduardo@digital2go.com" }

  s.platform              = :ios
  s.ios.deployment_target = '10.0'

  s.source                = { :git => "https://github.com/locally-io/DiscoverSDK.git", :tag => s.version }
  s.source_files          = "Source/**/*.swift"

  s.dependency 'AWSKinesis', '~> 2.6.22'
  s.dependency 'AWSCognito', '~> 2.6.22'
  s.dependency 'Reachability'
  s.dependency 'DeviceKit', '~> 1.3'
  s.dependency 'PromiseKit', '6.5.3'
  s.dependency 'Alamofire', '4.8.0'
end
