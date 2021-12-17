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

