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

    var client: EthereumClient?
    
    @Published var assetValue = String()
    @Published var fiatValue = String()
    
  
    private var subscriptions = Set<AnyCancellable>()

    //function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory amounts);
    public struct GetAmountsOut_Params: ABIFunction {
        public static let name = "getAmountsOut"
        public let gasPrice: BigUInt? = nil
        public let gasLimit: BigUInt? = nil
        public var contract: EthereumAddress = EthereumAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")
        public let from: EthereumAddress?

        public let amountIn: BigUInt
        public let path: [EthereumAddress]

        public init(from: EthereumAddress? = nil,
                    amountIn: BigUInt,
                    path: [EthereumAddress]) {
            
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
        public var contract: EthereumAddress = EthereumAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")
        public let from: EthereumAddress?

        public let amountOut: BigUInt
        public let path: [EthereumAddress]

        public init(from: EthereumAddress? = nil,
                    amountOut: BigUInt,
                    path: [EthereumAddress]) {
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
    
    
    init( /*walletManager: IWalletManager, adapterManager: AdapterManager*/ ) {
        print("SwapperViewModel init")

       
        let keyStorage = EthereumKeyLocalStorage()
        let account = try? EthereumAccount.create(keyStorage: keyStorage, keystorePassword: "MY_PASSWORD")
        guard let clientUrl = URL(string: "https://mainnet.infura.io/v3/c2e6a983caf749619a8f593f2f19fab3") else { return }
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
                print("FAILED GET BALANCE")
                //return completion(EthereumNameServiceError.ensUnknown, nil)
                return
            }
            
            if let amount: BigUInt = try? (try? ABIDecoder.decodeData(data, types: [BigUInt.self]))?.first?.decoded() {
                //completion(nil, ensAddress)
                print("BALANCE AMOUNT:")
                print(amount)
            } else {
                print("FAILED DECODE BALANCE")
                //completion(EthereumNameServiceError.decodeIssue, nil)
            }
          }
        )
        
        func getAmountsOut(param1: BigUInt) -> Future<BigUInt, Never> {
            return Future { [weak self] promisse in
                
                let getAmountsOut_Calldata = GetAmountsOut_Params(
                    amountIn: param1,
                    path: [
                        EthereumAddress("0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"),
                        EthereumAddress("0x514910771af9ca656af840dff83e8264ecf986ca")
                    ]
                )
                let tx2 = try? getAmountsOut_Calldata.transaction()
                
                
                self?.client?.eth_call(tx2!, block: .Latest, completion: { (error, data) in
                    guard let data = data, data != "0x" else {
                        promisse(.success(0))
                        return
                    }
                    
                    
                    do{
                        let decoded = try ABIDecoder.decodeData(data, types: [ABIArray<BigUInt>.self])
                        let arr : [BigUInt] = try decoded[0].decodedArray()
                        
                        if(arr.count == 0){
                            promisse(.success(0))
                            return
                        }
                        //completion(nil, ensAddress)
                        let amount = arr.last
                        
                        print("AMOUNTS OUT")
                        print(arr)
                                                
                        promisse(.success(amount!))
                        //self?.fiatValue = "\(amount)"
                    } catch let error {
                        print("FAILED TO DECODE AMOUNTS")
                        promisse(.success(0))
                    }
                })
            }
        }
        
        /*.map { [weak self]  in
            "\(($0 * (self?.price ?? 1.0)).rounded(toPlaces: 2))"
        }*/
        
        /*$assetValue
            .removeDuplicates()
            .compactMap { BigUInt($0) }
            .map { getAmountsOut(param1: $0) }
            

            //.sink { [weak self] value in
            //    self?.fiatValue = "\(value)"
            //}
            .sink(
                receiveCompletion: {
                    print($0)
                    //self?.fiatValue = $0
                },receiveValue: {
                    print($0)
                    self.fiatValue = "\($0)"
                }
            )
            .store(in: &subscriptions)*/
        
        $assetValue
            .removeDuplicates()
            .compactMap { BigUInt($0) }
            .map{ getAmountsOut(param1: $0) }
            .sink { future in
                future.receive(on: RunLoop.main).sink { [weak self] in
                   self?.fiatValue = "\($0)"
                }
                .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
        
        
        /*$fiatValue
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
            .store(in: &subscriptions)*/
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

extension SwapperViewModel {
    static func config() -> SwapperViewModel {
        let adapterManager = Portal.shared.adapterManager
        let walletManager = Portal.shared.walletManager
        
        return SwapperViewModel(
            //walletManager: walletManager,
            //adapterManager: adapterManager
        )
    }
}
