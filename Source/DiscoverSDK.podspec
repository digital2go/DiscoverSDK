Pod::Spec.new do |s|

  s.name         = "DiscoverSDK"
  s.version      = "0.5.2"
  s.summary      = "A framework that provides device information and data collecting"
  s.homepage     = "http://www.digital2go.com"
  s.license      = "MIT"
  s.author       = { "Eduardo Dias" => "eduardo@digital2go.com" }

  s.platform              = :ios
  s.ios.deployment_target = '10.0'

  s.source                = { :git => "https://edias@bitbucket.org/devbeasties/ios-discover-sdk.git", :tag => "v#{s.version}" }
  s.source_files          = "Source/**/*.swift"

  s.dependency 'AWSKinesis', '~> 2.6.22'
  s.dependency 'AWSCognito', '~> 2.6.22'
  s.dependency 'Reachability'
  s.dependency 'DeviceKit', '~> 1.3'

end