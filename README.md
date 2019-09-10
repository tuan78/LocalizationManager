# LocalizationManager

[![Version](https://img.shields.io/cocoapods/v/LocalizationManager.svg?style=flat)](https://cocoapods.org/pods/LocalizationManager)
[![License](https://img.shields.io/cocoapods/l/LocalizationManager.svg?style=flat)](https://cocoapods.org/pods/LocalizationManager)
[![Platform](https://img.shields.io/cocoapods/p/LocalizationManager.svg?style=flat)](https://cocoapods.org/pods/LocalizationManager)

###Lightweight localization handlers and tools for iOS:

* Set the app language at runtime without restarting app.
* Send notification when language and layout LTR direction changes.
* Check layout direction and update views automatically.
* Add Plural translation supports.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

Firstly,

```swift
import LocalizationManager
```

Start localization manager in AppDelegate

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

LocalizationManager.shared.start()

return true
}
```

Whenever you want to change language. Just add these codes below

```swift
// For English
LocalizationManager.shared.currentLanguage = "en"

// or for Chinese Simplified
LocalizationManager.shared.currentLanguage = "zh-Hans"
```

## Requirements

* iOS 9.0+
* Swift 4.2+

## Installation

LocalizationManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LocalizationManager'
```

## Author

Tuan Tran, tuantran070892@gmail.com

## License

LocalizationManager is available under the MIT license. See the LICENSE file for more info.
