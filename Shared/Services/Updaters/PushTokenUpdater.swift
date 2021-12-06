//
//  PushTokenUpdater.swift
//  Portal
//
//  Created by farid on 12/6/21.
//

import Foundation
import Combine

final class PushTokenUpdater {
    struct UpdateMessage: Decodable { let message: String }
    
    private let baseUrl: String = "https://cryptomarket-api.herokuapp.com/"
    private let jsonDecoder: JSONDecoder
    private var subscriptions = Set<AnyCancellable>()
    private var urlSession: URLSession
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        self.urlSession = URLSession(configuration: config)
    }
    
    func update(devId: String, token: String) {
        guard let url = URL(string: "\(baseUrl)register_user?dev_id=\(devId)&token=\(token)&platform=MacOs") else { return }
        
        urlSession.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: UpdateMessage.self, decoder: jsonDecoder)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: {  response in
                print("token update message: \(response.message)")
            }
            .store(in: &subscriptions)
    }
}
