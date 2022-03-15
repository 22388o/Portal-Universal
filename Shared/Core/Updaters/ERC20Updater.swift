//
//  ERC20Updater.swift
//  Portal
//
//  Created by Farid on 03.08.2021.
//

import Foundation
import Combine

protocol IERC20Updater {
    var tokens: [Erc20TokenCodable] { get }
    var onTokensUpdate: PassthroughSubject<[Erc20TokenCodable], Never> { get }
}

final class ERC20Updater: IERC20Updater {
    var onTokensUpdate = PassthroughSubject<[Erc20TokenCodable], Never>()
    
    var tokens: [Erc20TokenCodable] = []
    
    private let jsonDecoder: JSONDecoder
    private var subscriptions = Set<AnyCancellable>()
    
    private var urlSession: URLSession
        
    private var url: URL?
    
    init(jsonDecoder: JSONDecoder = JSONDecoder(), url: URL? = URL(string: "https://tokenlists.herokuapp.com/lists?chainId=3")) {
        self.jsonDecoder = jsonDecoder
        self.url = url
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        self.urlSession = URLSession(configuration: config)
        
        loadLocallyStoredTokens()
    }
    
    private func loadLocallyStoredTokens() {
        guard let data = RopstenERC20TokensResponse.data(using: .utf8) else { return }
        guard let response = try? jsonDecoder.decode(ERC20ListResponse.self, from: data) else { return }
        
        tokens = response.tokens.filter {
            !($0.logoURI?.isEmpty ?? true)
        }.map{
            Erc20TokenCodable(name: $0.name, symbol: $0.symbol, decimal: $0.decimals, contractAddress: $0.address, iconURL: $0.logoURI!)
        }
        
        onTokensUpdate.send(tokens)
        
//        fetchTokens()
    }
    
    private func fetchTokens() {
        guard let url = self.url else { return }
        
        urlSession.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: ERC20ListResponse.self, decoder: jsonDecoder)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] response in
                let valildTokens = response.tokens.filter { !($0.logoURI?.isEmpty ?? true) }.map{ Erc20TokenCodable(name: $0.name, symbol: $0.symbol, decimal: $0.decimals, contractAddress: $0.address, iconURL: $0.logoURI!) }
                print(valildTokens)
                
                self?.tokens = valildTokens
                self?.onTokensUpdate.send(valildTokens)
            }
            .store(in: &subscriptions)
    }
}
