# Portal-Universal
Portal wallet universal for iOS &amp; macOS

## nomenclature
- xcode = apple IDE
- cocoaPods = dependency manager for swift (written in ruby)
- branch: exchange-swiftui

## repo structure (names below ending in “/” are directories)
- .github/workflows/
  - yaml file for publishing to testflight
    - format required by github actions
- Pods/
  - all external dependencies
  - source copied from repos that we’ve modified
- Portal.xcodeproj/
  - created by xcode
- Portal.xcworkspace/
  - created by cocoaPods
- Shared/
  - source shared across all targets: macOS, ipadOS, iOS
  - Core/
    - Adapters/
  - DB/
    - Portal.xcdatamodeld/
      - schema description required by xcode
  - Services/
    - Manager/
    - Storage/
  - Models/
  - ViewModels/
  - Views/
- iOS/, macOS/
  - code specific to each target
  - primary difference is UI frameworks but also some extensions to macOS api
- Tests iOS/, Tests macOS/
  - template files to be filled out later
- Podfile
  - list of all depdendencies used by cocoaPods
- Podfile.lock	
  - output by cocoaPods
- altert.mp3
  - sounds used by the app

## control flow (dynamic paths of execution)
- boot
  - execution starts in:
    - for iOS: iOS/PortalApp.swift
    - for macOS: macOS/AppDelegate.swift
  - both of the above end up in Shared/Views/RootView.swift
