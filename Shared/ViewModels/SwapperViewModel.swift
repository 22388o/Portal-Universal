//
//  SwapperViewModel.swift
//  Portal
//
//  Created by Alexey Melnichenko on 8/19/21.
//

import Foundation
import Combine
import Coinpaprika
//import web3

import BigInt
import HdWalletKit

final class SwapperViewModel: ObservableObject {
    
    //SwapItem container
    class SwapItem: ObservableObject {
        @Published var token: Erc20Token
        @Published var value: String
        
        init(token: Erc20Token) {
            self.token = token
            self.value = "0"
        }
    }
    /*
    // Uses in replacement of web3's EthereumKeyLocalStorage, which stores raw private key in device documents folder ☠️
    private struct TempKeyStorage: EthereumKeyStorageProtocol {
        let key: HDPrivateKey
        
        func storePrivateKey(key: Data) throws {}
        func loadPrivateKey() throws -> Data {
            key.raw
        }
    }
    
    private var client: EthereumClient?
    private var account: EthereumAccount?
    private var walletEthereumAddress: EthereumAddress
    private var manager: EthereumKitManager
    */
     private(set) var tokenList : [Erc20Token] = [.LINK, .WETH, .BAND, .UNI, .MATIC, .USDT, .DAI]
    
    @Published var canSwap = false
    @Published var base = SwapItem(token: .WETH)
    @Published var quote = SwapItem(token: .DAI)
    @Published var slippage = String("0")
    
    private var subscriptions = Set<AnyCancellable>()
    /*
    //function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory amounts);
    private struct GetAmountsOutParams: ABIFunction {
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
    
    private struct SwapExactTokensForTokensParams: ABIFunction {
        public static let name = "swapExactTokensForTokens"
        public let gasPrice: BigUInt? = 170000000000
        public let gasLimit: BigUInt? = 300000
        public var contract: EthereumAddress = EthereumAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")
        public let from: EthereumAddress?
        
        public let amountIn: BigUInt
        public let amountOutMin: BigUInt
        public let path: [EthereumAddress]
        public let to: EthereumAddress
        public let deadline: BigUInt
        
        public init(
            from: EthereumAddress,
            amountIn: BigUInt,
            amountOutMin: BigUInt,
            path: [EthereumAddress],
            to: EthereumAddress,
            deadline: BigUInt
        ) {
            self.from = from
            self.amountIn = amountIn
            self.amountOutMin = amountOutMin
            self.path = path
            self.to = to
            self.deadline = deadline
        }
        
        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(amountIn)
            try encoder.encode(amountOutMin)
            try encoder.encode(path)
            try encoder.encode(to)
            try encoder.encode(deadline)
        }
    }
    
    private struct ApproveTokenToUniswapParams: ABIFunction {
        public static let name = "approve"
        public let gasPrice: BigUInt? = 170000000000
        public let gasLimit: BigUInt? = 100000
        public var contract: EthereumAddress = EthereumAddress("0xc778417e063141139fce010982780140aa0cd5ab")
        public let from: EthereumAddress?
        
        public let to: EthereumAddress// = EthereumAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")
        public let value: BigUInt
        
        public init(contract: EthereumAddress,
                    from: EthereumAddress,
                    to: EthereumAddress,
                    value: BigUInt) {
            
            self.contract = contract
            self.from = from
            self.value = value
            self.to = to
        }
        
        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(to)
            try encoder.encode(value)
        }
    }*/
    
    init(infuraId: String, manager: EthereumKitManager) {
        print("SwapperViewModel init")
        /*
        self.manager = manager
        walletEthereumAddress = EthereumAddress(manager.ethereumKit?.receiveAddress.hex ?? "0x00")
        
        //TODO: get base URL based on mainnet/testnet
        guard let clientUrl = URL(string: "https://ropsten.infura.io/v3/" + infuraId) else { return }
        client = EthereumClient(url: clientUrl)
        
        //Init new web3 account on every ether wallet update
        manager.currentAccountSubject.sink { [weak self] subject in
            guard subject != nil else { return }
            self?.initWeb3Account()
        }
        .store(in: &subscriptions)
        
        base.$value
            .compactMap { BigUInt($0) }
            .flatMap { bigInt in
                self.getAmountsOut(value: bigInt)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.quote.value = "\(value)"
                self?.canSwap = !(self?.base.value.isEmpty ?? true) && value > 0
            }
            .store(in: &subscriptions)
        
        //Reset value on swap items token update
        Publishers.Merge(base.$token, quote.$token)
            .sink { [weak self] _ in
                self?.base.value = "0"
                self?.quote.value = "0"
            }
            .store(in: &subscriptions)
         */
    }
    /*
    private func initWeb3Account() {
        guard let privKey = manager.privateKey(), let pubKey = manager.publicKey() else { return }
        
        let keyStorage = TempKeyStorage(key: privKey)
        
        guard let account = try? EthereumAccount(keyStorage: keyStorage) else {
            print("CANNOT INIT ETH ACCOUNT ERROR")
            return
        }
        
        self.account = account
        
        print("ACCOUNT ADDRESS", account.address, pubKey) //TODO: make sure this address matches the Ethereum address in wallet
        
        self.walletEthereumAddress = account.address
    }
    
    private func getAmountsOut(value: BigUInt) -> Future<BigUInt, Never> {
        Future { [weak self] promise in
            
            //            self?.slippage = (BigUInt(10000000000000000)/value).description + "%"
            
            guard
                value > 0,
                let baseContractAddress = self?.base.token.contractAddress,
                let quoteContractAddress = self?.quote.token.contractAddress
            else {
                promise(.success(0))
                return
            }
            
            let getAmountsOutCalldata = GetAmountsOutParams(
                amountIn: value,// * BigUInt(1e18), //TODO convert to int and append up to 1eDECIMALS
                path: [
                    EthereumAddress(baseContractAddress),
                    EthereumAddress(quoteContractAddress)
                ]
            )
            
            guard let transaction = try? getAmountsOutCalldata.transaction() else {
                promise(.success(0))
                return
            }
            
            self?.client?.eth_call(transaction, block: .Latest, completion: { (error, data) in
                guard let data = data, data != "0x" else {
                    promise(.success(0))
                    return
                }
                
                do{
                    let decoded = try ABIDecoder.decodeData(data, types: [ABIArray<BigUInt>.self])
                    let decoderArray : [BigUInt] = try decoded[0].decodedArray()
                    
                    if decoderArray.isEmpty {
                        promisse(.success(0))
                        return
                    }
                    
                    guard let amount = decoderArray.last else {
                        promisse(.success(0))
                        return
                    }
                    
                    print("AMOUNTS OUT")
                    print(decoderArray)
                    
                    promise(.success(amount))
                } catch let error {
                    print("FAILED TO DECODE AMOUNTS: \(error.localizedDescription)")
                    promise(.success(0))
                }
            })
        }
    }
    */
    func approveToken() {
        /*
        let target = EthereumAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")
        
        print("APPROVING", base.token.contractAddress, "TO", target)
        
        let calldata = ApproveTokenToUniswapParams(
            contract: EthereumAddress(base.token.contractAddress),
            from: walletEthereumAddress,
            to: target,
            value: BigUInt( 99999999999999999 )
        )
        
        guard
            let transaction = try? calldata.transaction(),
            let account = self.account
        else { return }
        
        client?.eth_sendRawTransaction(transaction, withAccount: account) { (error, txHash) in
            if let txError = error {
                print("TX Error: \(txError)")
            } else if let hash = txHash {
                print("TX Hash: \(hash)")
            }
        }
         */
    }
    
    func doSwap(){
        /*
        print("DOING SWAP")
        
        let amtIn = BigUInt(base.value)
        guard let amountIn = amtIn else { print("invalid amount in"); return }
        
        let amtOut = BigUInt(quote.value)
        guard let amountOut = amtOut else { print("invalid amount out"); return }
        
        let deadline: BigUInt = BigUInt(Date().timeIntervalSince1970 + 300)
        print("DEADLINE TIMESTAMP", deadline)
        
        let calldata = SwapExactTokensForTokensParams(
            from: walletEthereumAddress,
            amountIn: amountIn,
            amountOutMin: amountOut,
            path: [
                EthereumAddress(base.token.contractAddress),
                EthereumAddress(quote.token.contractAddress)
            ],
            to: walletEthereumAddress,
            deadline: deadline
        )
        
        guard
            let transaction = try? calldata.transaction(),
            let account = self.account
        else { return }
        
        print("SENDING TX")
        
        client?.eth_sendRawTransaction(transaction, withAccount: account) { (error, txHash) in
            if let txError = error {
                print("TX error", txError)
            } else if let hash = txHash {
                print("TX Hash: \(hash)")
            }
        }
         */
    }
    
    func reset() {
        base.value = String()
    }
    
    deinit {
        print("SwapperViewModel deinit")
    }
}

extension SwapperViewModel {
    static func config() -> SwapperViewModel {
        let infuraId = Portal.shared.appConfigProvider.infuraCredentials.id
        let manager = Portal.shared.ethereumKitManager
        
        return SwapperViewModel(infuraId: infuraId, manager: manager)
    }
}
