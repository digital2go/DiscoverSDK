# Requirements
---- 
* iOS 10 +
* Xcode 10 +
* Swift 4.2 +
* Cocoapods

# Installation
---- 
## CocoaPods
Cocoapods is a dependency management platform to install, update and delete the libraries used on the project.
  
  
You can  install Cocoapods with the following terminal command
   
```ruby
$ sudo gem install cocoapods
```
    
To initialize Cocoapods on your project, navigate through the terminal to your project directory and run this command:
```ruby
$ cocoapods init
```

This will create a .podfile on the root of your project. The .podfile is the configuration file that Cocoapods use to declare the project dependencies. 

Add the Discovery SDK as a dependency to your project like this.
  
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Your Target Name' do
    pod 'DiscoverySDK'
end
```

On the root of your project where the Podfile was created run the following command to install the Discovery SDK as a dependency.

```ruby
$ pod install
```

## Configuring  Discovery SDK

Add the following keys to the plist of your app. Discover SDK will need these permissions to track user location.

- NSBluetoothPeripheralUsageDescription
- NSLocationAlwaysAndWhenInUseUsageDescription
- NSLocationWhenInUseUsageDescription

# Usage
---- 
## Connecting the Discover SDK  

To start using the Discover SDK simply call the **connect** operation.  

```swift
DiscoverSDK.shared.connect()
```

The discover SDK will request location permission from your app and after authorized  it will start recording immediately. The default configuration records data every 20 seconds and streaming it every minute.

This enough to have the Discover SDK installed configured and running into your app.

# Using Delegates

Discover SDK can add a more fine grain control over each step of the permissions or recording process in your App.

## Location Permissions Delegate
  
To receive updates about location permissions just add a location delegate and implement the required operations.  
  
```swift
DiscoverSDK.shared.locationDelegate = self
DiscoverSDK.shared.connect()
```
    
Implement the following operations in your delegate
  
```swift
extension MyClass: DiscoverSDKLocationDelegate {

	func didAuthorizedLocationMonitoring() {
		// Your code here
	}

	func didNotAuthorizedLocationMonitoring() {
		// Your code here
	}
}
```
