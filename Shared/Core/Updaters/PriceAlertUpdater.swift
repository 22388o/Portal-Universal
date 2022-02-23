//
//  PriceAlertUpdater.swift
//  Portal
//
//  Created by farid on 12/7/21.
//

import Foundation
import Combine

final class PriceAlertUpdater {
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
    
    func createAlert(devId: String, alertId: String, coin: String, price: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseUrl)create_alert?dev_id=\(devId)&id=\(alertId)&coin=\(coin)$price=\(price)") else {
            return completion("Api call url isn't valid")
        }
        
        urlSession.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: UpdateMessage.self, decoder: jsonDecoder)
            .sink { result in
                if case let .failure(error) = result {
                    completion(error.localizedDescription)
                }
            } receiveValue: {  response in
                print("Price alert created with message: \(response.message)")
                completion(response.message)
            }
            .store(in: &subscriptions)
    }
    
    func deleteAlert(alertId: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseUrl)delete_alert?id=\(alertId)") else {
            return completion("Api call url isn't valid")
        }
        
        urlSession.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: UpdateMessage.self, decoder: jsonDecoder)
            .sink { result in
                if case let .failure(error) = result {
                    completion(error.localizedDescription)
                }
            } receiveValue: {  response in
                print("Price alert deleted with message: \(response.message)")
                completion(response.message)
            }
            .store(in: &subscriptions)
    }
}
