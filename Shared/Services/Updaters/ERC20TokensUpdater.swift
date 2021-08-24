//
//  ERC20TokensUpdater.swift
//  Portal
//
//  Created by Farid on 03.08.2021.
//

import Foundation
import Combine

final class ERC20TokensUpdater {
    var onTokensUpdatePublisher = PassthroughSubject<[Erc20TokenCodable], Never>()
    
    private var tokens: [Erc20TokenCodable] = []
    
    private let jsonDecoder: JSONDecoder
    private var subscriptions = Set<AnyCancellable>()
        
    private var url: URL? {
        URL(string: "https://cryptomarket-api.herokuapp.com/erc20_token_list")
    }
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        updateErc20TokensData()
    }
    
    private func loadLocallyStoredTokens() {
        guard let data = erc20JSON.data(using: .utf8) else { return }
        guard let allTokens = try? jsonDecoder.decode([String : Erc20TokenCodable].self, from: data) else { return }
        
        tokens = allTokens.map{ $0.value }.filter { !$0.iconURL.isEmpty }
        onTokensUpdatePublisher.send(tokens)
    }
    
    private func updateErc20TokensData() {
        guard let url = self.url else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: [String : Erc20TokenCodable].self, decoder: jsonDecoder)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                    self?.loadLocallyStoredTokens()
                }
            } receiveValue: { [weak self] erc20Tokens in
                let valildTokens = erc20Tokens.map{ $0.value }.filter { !$0.iconURL.isEmpty }
                self?.tokens = valildTokens
                self?.onTokensUpdatePublisher.send(valildTokens)
            }
            .store(in: &subscriptions)
    }
}
