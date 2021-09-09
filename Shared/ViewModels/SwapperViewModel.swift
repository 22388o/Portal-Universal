//
//  SwapperViewModel.swift
//  Portal
//
//  Created by Alexey Melnichenko on 8/19/21.
//

import Foundation
import Combine
import Coinpaprika
import web3


final class SwapperViewModel: ObservableObject {
    let coin: Coin
    let fiat: FiatCurrency
    
    @Published var assetValue = String()
    @Published var fiatValue = String()
    
    private var price: Double {
        ((ticker?[.usd].price ?? 0) * Decimal(fiat.rate)).double
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    var ticker: Ticker? {
        Portal.shared.marketDataProvider.ticker(coin: coin)
    }
    
    //function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory amounts);
    public struct GetAmountsOut: ABIFunction {
        public static let name = "transfer"
        public let gasPrice: BigUInt? = nil
        public let gasLimit: BigUInt? = nil
        public var contract: EthereumAddress
        public let from: EthereumAddress?

        public let amountIn: BigUInt
        public let path: [EthereumAddress]

        public init(contract: EthereumAddress,
                    from: EthereumAddress? = nil,
                    amountIn: BigInt,
                    path: [EthereumAddress]) {
            self.contract = contract
            self.from = from
            self.amountIn = amountIn
            self.path = path
        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(amountIn)
            try encoder.encode(path)
        }
    }
    
    init(coin: Coin, fiat: FiatCurrency) {
        print("SwapperViewModel init")

        self.coin = coin
        self.fiat = fiat
        
        let keyStorage = EthereumKeyLocalStorage()
        let account = try? EthereumAccount.create(keyStorage: keyStorage, keystorePassword: "MY_PASSWORD")
        guard let clientUrl = URL(string: "https://an-infura-or-similar-url.com/123") else { return }
        self.client = EthereumClient(url: clientUrl)
        
        $assetValue
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { [weak self] in
                "\(($0 * (self?.price ?? 1.0)).rounded(toPlaces: 2))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.fiatValue = "0"
                } else {
                    self?.fiatValue = value
                }
            }
            .store(in: &subscriptions)
        
        $fiatValue
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { [weak self] in
                "\(($0/(self?.price ?? 1.0)).rounded(toPlaces: 6))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.assetValue = "0"
                } else {
                    self?.assetValue = value
                }
            }
            .store(in: &subscriptions)
    }
    
    func onValueChanged(){
        
    }
    
    func reset() {
        assetValue = String()
    }
    
    deinit {
        print("SwapperViewModel deinit")
    }
}

