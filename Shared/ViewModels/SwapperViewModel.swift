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
import HdWalletKit


final class SwapperViewModel: ObservableObject {

    var client: EthereumClient?
    var account: EthereumAccount?
    var myaddress: EthereumAddress
    
    var initializedWeb3 : Bool = false
    
    @Published var assetValue = String()
    @Published var fiatValue = String()
    
    @Published var slippage = String("0")
    
    @Published var tokenList : [Erc20Token] = [
        Erc20Token( name:"ChainLink", symbol:"LINK", decimal:18,
            contractAddress:"0x514910771af9ca656af840dff83e8264ecf986ca",
            iconURL: "https://cryptologos.cc/logos/chainlink-link-logo.png"),
        Erc20Token( name:"Wrapped Ether", symbol:"WETH", decimal:18,
            //contractAddress:"0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            contractAddress: "0xc778417e063141139fce010982780140aa0cd5ab",
            iconURL: "https://cryptologos.cc/logos/ethereum-eth-logo.png"),
        Erc20Token( name:"BandToken", symbol:"BAND", decimal:18,
            contractAddress:"0xba11d00c5f74255f56a5e366f4f77f5a186d7f55",
            iconURL: "https://assets.coingecko.com/coins/images/9545/thumb/band-protocol.png"),
        Erc20Token( name:"UniswapToken", symbol:"UNI", decimal:18,
            contractAddress:"0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
            iconURL: "https://cloudflare-ipfs.com/ipfs/QmXttGpZrECX5qCyXbBQiqgQNytVGeZW5Anewvh2jc4psg/"),
        Erc20Token( name:"Polygon", symbol:"MATIC", decimal:18,
            contractAddress:"0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0",
            iconURL: "https://raw.githubusercontent.com/Uniswap/assets/master/blockchains/ethereum/assets/0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0/logo.png"),
        Erc20Token( name:"Tether USD", symbol:"USDT", decimal:6,
                    contractAddress: "0x110a13fc3efe6a245b50102d2d79b3e76125ae83",
                    iconURL: "https://w7.pngwing.com/pngs/202/402/png-transparent-tether-cryptocurrency-price-market-capitalization-computer-icons-others-white-logo-author-thumbnail.png"),
        Erc20Token( name: "DAI USD", symbol: "DAI", decimal:18,
                    contractAddress: "0xad6d458402f60fd3bd25163575031acdce07538d",
                    iconURL: "https://cryptologos.cc/logos/multi-collateral-dai-dai-logo.png")
    ]
    
    @Published var selectionA : Erc20Token = Erc20Token( name:"Wrapped Ether",
                                                         symbol:"WETH",
                                                         decimal:18,
                                                         //contractAddress:"0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
                                                         contractAddress: "0xc778417e063141139fce010982780140aa0cd5ab",
                                                         iconURL: "https://cryptologos.cc/logos/ethereum-eth-logo.png")
    
    @Published var selectionB : Erc20Token = Erc20Token( name:"ChainLink",
                                                         symbol:"DAI",
                                                         decimal:18,
                                                         //contractAddress:"0x514910771af9ca656af840dff83e8264ecf986ca",
                                                         contractAddress: "0xad6d458402f60fd3bd25163575031acdce07538d",
                                                         iconURL: "https://cryptologos.cc/logos/multi-collateral-dai-dai-logo.png"
                                                            //"https://cryptologos.cc/logos/chainlink-link-logo.png"
    )
    

    
    private var subscriptions = Set<AnyCancellable>()
    
    
    //function allowance(address account, address spender)
    public struct GetAllowance_Params: ABIFunction {
        public static let name = "allowance"
        public let gasPrice: BigUInt? = nil
        public let gasLimit: BigUInt? = nil
        public var contract: EthereumAddress
        public let from: EthereumAddress?

        public let account: EthereumAddress
        public let spender: EthereumAddress

        public init(from: EthereumAddress? = nil,
                    contract: EthereumAddress,
                    account: EthereumAddress,
                    spender: EthereumAddress) {
            
            self.from = from
            self.contract = contract
            self.account = account
            self.spender = spender
        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(account)
            try encoder.encode(spender)
        }
    }
    
    //function decimals()
    public struct GetDecimals_Params: ABIFunction {
        public static let name = "decimals"
        public let gasPrice: BigUInt? = nil
        public let gasLimit: BigUInt? = nil
        public var contract: EthereumAddress
        public let from: EthereumAddress?

        public init(from: EthereumAddress? = nil,
                    contract: EthereumAddress) {
            
            self.from = from
            self.contract = contract
        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
        }
    }
    
    //function approve()
    public struct Approve_Params: ABIFunction {
        public static let name = "approve"
        public let gasPrice: BigUInt? = 170000000000
        public let gasLimit: BigUInt? = 300000
        public var contract: EthereumAddress
        public let from: EthereumAddress?

        public let spender: EthereumAddress
        public let amount: BigUInt
        
        public init(
            from: EthereumAddress,
            contract: EthereumAddress,
            spender: EthereumAddress,
            amount: BigUInt
        ) {
            self.from = from
            self.contract = contract
            self.spender = spender
            self.amount = amount
        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(spender)
            try encoder.encode(amount)
        }
    }
    
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
    
    /* function swapExactTokensForTokens(
           uint amountIn,
           uint amountOutMin,
           address[] calldata path,
           address to,
           uint deadline
     )*/
    public struct SwapExactTokensForTokens_Params: ABIFunction {
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
    
    public struct ApproveTokenToUniswap_Params: ABIFunction {
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
    }
    
    func initWeb3Account(){
        let manager = Portal.shared.ethereumKitManager
       
        if self.initializedWeb3 {
            return
        }
            
        let key = manager.privateKey()
        let pubkey = manager.publicKey() //get public key for compare
                    
        if key == nil {
            return;
        }else{
            self.initializedWeb3 = true
        }
                
        let base64key = key!.raw.base64EncodedString() //TODO: figure out why it's deriving incorrect address
        
        print("USING KEY", key!.raw)
                
        let keyData = Data(base64Encoded: base64key)!
        let keyStorage = EthereumKeyLocalStorage()
        
        do {
            try keyStorage.storePrivateKey(key: keyData)
            let storedData = try keyStorage.loadPrivateKey()
            print("STORED KEY CORRECT?")
            print(storedData == keyData)
        } catch {
            print("FAILED TO LOAD PRIVATE KEY")
        }
        
        //let account = try? EthereumAccount.create(keyStorage: keyStorage, keystorePassword: "MY_PASSWORD")
        let account = try! EthereumAccount(keyStorage: keyStorage)
        self.account = account
        print("ACCOUNT ADDRESS", account.address, pubkey) //TODO: make sure this address matches the Ethereum address in wallet
        self.myaddress = account.address
        //let account = try! EthereumAccount(keyStorage: keyStorage)
    }
    
    func getBalance(){
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
    }
    
    init( /*walletManager: IWalletManager, adapterManager: AdapterManager*/ ) {
        print("SwapperViewModel init")
            
        self.account = nil
        self.myaddress = EthereumAddress("0x00");
        
        let infuraCreds = Portal.shared.appConfigProvider.infuraCredentials
        print("INFURA CREDS", infuraCreds)
        
        //TODO: get base URL based on mainnet/testnet
        guard let clientUrl = URL(string: "https://ropsten.infura.io/v3/" + infuraCreds.id) else { return }
        self.client = EthereumClient(url: clientUrl)
        
        
        func getAmountsOut(param1: BigUInt) -> Future<BigUInt, Never> {
            return Future { [weak self] promisse in
                
                //self?.slippage = (BigUInt(10000000000000000)/param1).description + "%"
                
                let addressA : String = self?.selectionA.contractAddress ?? "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
                let addressB : String = self?.selectionB.contractAddress ?? "0x514910771af9ca656af840dff83e8264ecf986ca"
                
                let getAmountsOut_Calldata = GetAmountsOut_Params(
                    amountIn: param1,// * BigUInt(1e18), //TODO convert to int and append up to 1eDECIMALS
                    path: [
                        EthereumAddress(addressA),
                                        //"0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"),
                        EthereumAddress(addressB)
                                        //"0x514910771af9ca656af840dff83e8264ecf986ca")
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
                        var amount : BigUInt? = arr.last
                        
                        amount = amount! // / BigUInt(1e18) //divide by 1eDECIMALS
                        
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
        
        $assetValue
            .removeDuplicates()
            .compactMap { BigUInt($0) }
            .map{ getAmountsOut(param1: $0) }
            .sink { future in
                self.initWeb3Account()
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
    
    func approveToken() {
        initWeb3Account()
        
        let myaccount = self.myaddress;
        let target = EthereumAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")
        
        print("APPROVING", self.selectionA.contractAddress, "TO", target)
        
        let calldata = ApproveTokenToUniswap_Params(
            contract: EthereumAddress(self.selectionA.contractAddress),
            from: myaccount,
            to: target,
            value: BigUInt( 99999999999999999 )
        )
        let tx2 = try? calldata.transaction()
        let account = self.account!
                                        
        self.client?.eth_sendRawTransaction(tx2!, withAccount: account) { (error, txHash) in
            if(error != nil){
                print("TX error?", error!)
                //promisse(.success(0))
            }else{
                print("TX Hash: \(txHash!)")
                //promisse(.success(1))
            }
        }
    }
    
    
    func doSwap(){
        print("DOING SWAP")
            
        let amtIn = BigUInt( self.assetValue )
        let amtOut = BigUInt( self.fiatValue )
        
        if(amtIn == nil){
            print("invalid amount in")
            return
        }
        if(amtOut == nil){
            print("invalid amount out")
            return
        }
        
        let deadline : BigUInt = BigUInt(NSDate().timeIntervalSince1970 + 300)
        print("DEADLINE TIMESTAMP", deadline)
               
        let calldata = SwapExactTokensForTokens_Params(
            from: self.myaddress,
            amountIn: amtIn!,
            amountOutMin: amtOut!,
            path: [
                EthereumAddress(self.selectionA.contractAddress),//EthereumAddress("0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"),
                EthereumAddress(self.selectionB.contractAddress)//EthereumAddress("0x514910771af9ca656af840dff83e8264ecf986ca")
            ],
            to: self.myaddress,
            deadline: deadline
        )
        let tx2 = try? calldata.transaction()
        let account = self.account!
                                        
        print("SENDING TX")
        self.client?.eth_sendRawTransaction(tx2!, withAccount: account) { (error, txHash) in
            if(error != nil){
                print("TX error?", error!)
                //promisse(.success(0))
            }else{
                print("TX Hash: \(txHash!)")
                //promisse(.success(1))
            }
        }
    }
    
    func approveWeth(){
        print("APPROVING WETH")
        approveToken();
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
