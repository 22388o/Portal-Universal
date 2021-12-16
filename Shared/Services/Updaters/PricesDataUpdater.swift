//
//  PricesDataUpdater.swift
//  Portal
//
//  Created by Farid on 16.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine

typealias PriceResponse = Dictionary<String, Dictionary<String, MarketPrice>>

final class PricesDataUpdater: IPricesData {
    var onPricesUpdate = PassthroughSubject<PriceResponse, Never>()
    
    private let jsonDecoder: JSONDecoder
    private let timer: RepeatingTimer
    private var task: URLSessionTask?
    private var urlSession: URLSession
    private var url: URL? {
        URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD,EUR")
    }
        
    init(
        jsonDecoder: JSONDecoder = JSONDecoder(),
        interval: TimeInterval
    ) {
        self.jsonDecoder = jsonDecoder
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        self.urlSession = URLSession(configuration: config)

        self.timer = RepeatingTimer(timeInterval: interval)
        self.timer.eventHandler = { [weak self] in
            guard self?.task?.state != .running else { return }
            
            self?.updatePrices(for: "") { result in
                guard let self = self else { return }
                switch result {
                case let .success(prices):
                    self.onPricesUpdate.send(prices)
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
        self.timer.resume()
    }
            
    func updatePrices(for assets: String, _ competionHandler: @escaping ((Result<PriceResponse, NetworkError>) -> Void)) {
        guard let url = self.url else {
            competionHandler(.failure(.missingURL))
            return
        }
        task = urlSession.dataTask(with: url) { data, response, error in
            switch (data, error) {
            case (_, .some):
                competionHandler(.failure(.networkError))
            case let (.some(data), nil):
                guard let mockResponse = fullPriceResponse.data(using: .utf8) else {
                    return
                }
                guard let response = try? self.jsonDecoder.decode(PriceResponse.self, from: mockResponse) else {
                    competionHandler(.failure(.parsingError))
                    return
                }
                competionHandler(.success(response))
            case (nil, nil):
                competionHandler(.failure(.inconsistentBehavior))
            }
        }
        task?.resume()
    }
    
    func pause() {
        timer.suspend()
    }
    
    func resume() {
        timer.resume()
    }
}
