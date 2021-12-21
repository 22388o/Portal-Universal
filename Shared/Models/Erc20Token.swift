//
//  Erc20TokenCodable.swift
//  Portal
//
//  Created by Farid on 30.07.2021.
//

import Foundation

struct Erc20Token {
    let name: String
    let symbol: String
    let decimal: Int
    let contractAddress: String
    var iconURL = String()
    
    struct Logo: Codable {
        let src: String?
    }
}

extension Erc20Token {
    static var LINK: Erc20Token {
        Erc20Token(
            name:"ChainLink",
            symbol:"LINK",
            decimal:18,
            contractAddress:"0x514910771af9ca656af840dff83e8264ecf986ca",
            iconURL: "https://cryptologos.cc/logos/chainlink-link-logo.png"
        )
    }
    
    static var WETH: Erc20Token {
        Erc20Token(
            name:"Wrapped Ether",
            symbol:"WETH",
            decimal:18,
            contractAddress: "0xc778417e063141139fce010982780140aa0cd5ab",
            iconURL: "https://cryptologos.cc/logos/ethereum-eth-logo.png"
        )
    }
    
    static var BAND: Erc20Token {
        Erc20Token(
            name:"BandToken",
            symbol:"BAND",
            decimal:18,
            contractAddress:"0xba11d00c5f74255f56a5e366f4f77f5a186d7f55",
            iconURL: "https://assets.coingecko.com/coins/images/9545/thumb/band-protocol.png"
        )
    }
    
    static var UNI: Erc20Token {
        Erc20Token(
            name:"UniswapToken",
            symbol:"UNI",
            decimal:18,
            contractAddress:"0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
            iconURL: "https://cloudflare-ipfs.com/ipfs/QmXttGpZrECX5qCyXbBQiqgQNytVGeZW5Anewvh2jc4psg/"
        )
    }
    
    static var MATIC: Erc20Token {
        Erc20Token(
            name:"Polygon",
            symbol:"MATIC",
            decimal:18,
            contractAddress:"0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0",
            iconURL: "https://raw.githubusercontent.com/Uniswap/assets/master/blockchains/ethereum/assets/0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0/logo.png"
        )
    }
    
    static var USDT: Erc20Token {
        Erc20Token(
            name:"Tether USD",
            symbol:"USDT",
            decimal:6,
            contractAddress: "0x110a13fc3efe6a245b50102d2d79b3e76125ae83",
            iconURL: "https://w7.pngwing.com/pngs/202/402/png-transparent-tether-cryptocurrency-price-market-capitalization-computer-icons-others-white-logo-author-thumbnail.png"
        )
    }
    
    static var DAI: Erc20Token {
        Erc20Token(
            name: "DAI USD",
            symbol: "DAI",
            decimal:18,
            contractAddress: "0xad6d458402f60fd3bd25163575031acdce07538d",
            iconURL: "https://cryptologos.cc/logos/multi-collateral-dai-dai-logo.png"
        )
    }
}

extension Erc20Token: Codable {
    enum Keys: String, CodingKey {
        case name
        case symbol
        case decimal = "decimals"
        case contractAddress = "address"
        case logo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        decimal = try container.decode(Int.self, forKey: .decimal)
        contractAddress = try container.decode(String.self, forKey: .contractAddress)
        
        do {
            let urlString = try container.decode(Logo.self, forKey: .logo).src
            if let imgUrl = urlString {
                iconURL = imgUrl
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

