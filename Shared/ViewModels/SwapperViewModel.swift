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

import BigInt

final class SwapperViewModel: ObservableObject {
    let coin: Coin
    let fiat: FiatCurrency
    var client: EthereumClient?
    
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
    public struct GetAmountsOut_Params: ABIFunction {
        public static let name = "getAmountsOut"
        public let gasPrice: BigUInt? = nil
        public let gasLimit: BigUInt? = nil
        public var contract: EthereumAddress
        public let from: EthereumAddress?

        public let amountIn: BigUInt
        public let path: [EthereumAddress]

        public init(contract: EthereumAddress,
                    from: EthereumAddress? = nil,
                    amountIn: BigUInt,
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
    
    public struct GetAmountsIn_Params: ABIFunction {
        public static let name = "getAmountsIn"
        public let gasPrice: BigUInt? = nil
        public let gasLimit: BigUInt? = nil
        public var contract: EthereumAddress
        public let from: EthereumAddress?

        public let amountOut: BigUInt
        public let path: [EthereumAddress]

        public init(contract: EthereumAddress,
                    from: EthereumAddress? = nil,
                    amountOut: BigUInt,
                    path: [EthereumAddress]) {
            self.contract = contract
            self.from = from
            self.amountOut = amountOut
            self.path = path
        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(amountOut)
            try encoder.encode(path)
        }
    }
    
    
    struct BalanceOf_Parameter: ABIFunction {
        static let name = "balanceOf"
        let gasPrice: BigUInt? = nil
        let gasLimit: BigUInt? = nil
        var contract: EthereumAddress
        let account: EthereumAddress
        let from: EthereumAddress? = nil
        
        func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(account)
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
        
        //get balance of user for token
        let balanceOf_Calldata = BalanceOf_Parameter(
            contract: EthereumAddress("0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2"),
            account: EthereumAddress("0x05E793cE0C6027323Ac150F6d45C2344d28B6019")
        )
        
        let tx = try? balanceOf_Calldata.transaction()
        client?.eth_call(tx!,
          block: .Latest,
          completion: { (error, data) in
            guard let data = data, data != "0x" else {
                //return completion(EthereumNameServiceError.ensUnknown, nil)
                return
            }
            
            if let amount: BigUInt = try? (try? ABIDecoder.decodeData(data, types: [BigUInt.self]))?.first?.decoded() {
                //completion(nil, ensAddress)
            } else {
                //completion(EthereumNameServiceError.decodeIssue, nil)
            }
          }
        )
        
        func yourFunctionName(param1: BigUInt) -> Future<BigUInt, Never> {
            return Future { [weak self] promisse in
                self?.client?.eth_call(tx!, block: .Latest, completion: { (error, data) in
                    guard let data = data, data != "0x" else {
                        promisse(.success(0))
                        return
                    }
                    if let amount: BigUInt = try? (try? ABIDecoder.decodeData(data, types: [BigUInt.self]))?.first?.decoded() {
                        promisse(.success(amount))
                    } else {
                        promisse(.success(0))
                    }
                })
            }
        }
        
        /*.map { [weak self]  in
            "\(($0 * (self?.price ?? 1.0)).rounded(toPlaces: 2))"
        }*/
        
        $assetValue
            .removeDuplicates()
            .map { BigUInt($0) }
            .map { yourFunctionName(param: $0) }
            .sink { [weak self] value in
                self?.fiatValue = "\(value)"
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

