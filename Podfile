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
  #MarketData
  pod 'CoinpaprikaAPI'
  #Charts
  pod 'Charts', :git => 'https://github.com/danielgindi/Charts.git', :commit => '97587d04ed51f4e38e3057da51867d8805995a56'
  #Keychain
  pod 'KeychainAccess'
  #Async image
  pod 'Kingfisher', :git => 'https://github.com/onevcat/Kingfisher', :commit => '8c73044cd5f6754ce605da05e2a4dab891d1aa0a'
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

  # Pods for Portal (macOS)
  portal_shared_pods

end
