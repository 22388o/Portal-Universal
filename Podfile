source 'https://cdn.cocoapods.org/'

def portal_shared_pods
  #Kits
  pod 'BitcoinCore-Universal.swift'
  pod 'BitcoinKit-Universal.swift'
  pod 'EthereumKit-Universal'
  pod 'Erc20Kit-Universal'
  #ToolKits
  pod 'HsToolKit-Universal.swift'
  pod 'Hodler-Universal.swift'
  pod 'FeeRateKit-Universal.swift'
  pod 'CryptoSwift', '~> 1.4.1'
  #MarketData
  pod 'CoinpaprikaAPI'
  #Charts
  pod 'Charts', :git => 'https://github.com/danielgindi/Charts.git', :commit => '97587d04ed51f4e38e3057da51867d8805995a56'
  #Keychain
  pod 'KeychainAccess'
  #Async image
  pod 'Kingfisher', '~> 6.3.0'
  #Soket framework
  pod 'Socket.IO-Client-Swift', '~> 15.2.0'
  #Analytics
  pod 'Mixpanel-swift'
  #Error monitoring
  pod 'Bugsnag'
  #Tools
  pod 'RxCombine'
end


target 'Portal (iOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  platform :ios, '13.0'
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Portal (iOS)
  portal_shared_pods
  

end

target 'Portal (macOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  platform :osx, '10.15'
  use_frameworks!
  inhibit_all_warnings!
  
  pod 'Sparkle'
  
  # Pods for Portal (macOS)
  portal_shared_pods
end

target 'UnitTestsIOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  platform :ios, '13.0'
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Tests iOS
  portal_shared_pods
  

end

target 'UnitTestsMacOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  platform :osx, '10.15'
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Tests macOS
  portal_shared_pods
  

end
