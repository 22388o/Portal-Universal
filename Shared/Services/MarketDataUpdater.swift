//
//  MarketDataUpdater.swift
//  Portal
//
//  Created by Farid on 16.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine

final class MarketDataUpdater: IHistoricalData {
    var onUpdatePublisher = PassthroughSubject<(MarketDataRange, HistoricalDataResponse), Never>()
    
    private let marketDataQueue = DispatchQueue(label: "com.portal.market.data.queue", attributes: .concurrent)
    private let jsonDecoder: JSONDecoder
    
    private var hourDataTask: URLSessionTask?
    private var dayDataTask: URLSessionTask?
    private var weekDataTask: URLSessionTask?
    private var monthDataTask: URLSessionTask?
    private var yearDataTask: URLSessionTask?

    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        self.fetchHistoricalData(assets: "BTC, BCH, ETH")
    }
    
    func fetchHistoricalData(assets: String) {
        marketDataQueue.async { [weak self] in
            self?.fetchHourData(assets: assets) { result in
                switch result {
                case let .success(data):
                    self?.onUpdatePublisher.send((.hour, data))
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
            self?.fetchDayData(assets: assets) { result in
                switch result {
                case let .success(data):
                self?.onUpdatePublisher.send((.day, data))
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
            self?.fetchWeekData(assets: assets) { result in
                switch result {
                case let .success(data):
                self?.onUpdatePublisher.send((.week, data))
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
            self?.fetchMonthData(assets: assets) { result in
                switch result {
                case let .success(data):
                self?.onUpdatePublisher.send((.month, data))
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
            self?.fetchYearData(assets: assets) { result in
                switch result {
                case let .success(data):
                self?.onUpdatePublisher.send((.year, data))
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchHourData(assets: String,  _ competionHandler: @escaping ((Result<HistoricalDataResponse, NetworkError>) -> Void)) {
        guard hourDataTask?.state != .running else { return }
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD,EUR") else {
            competionHandler(.failure(.networkError))
            return
        }
        hourDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            switch (data, error) {
            case (_, .some):
                competionHandler(.failure(.networkError))
            case let (.some(data), nil):
                guard let mockResponse = hourDataResponse.data(using: .utf8) else {
                    return
                }
                guard let response = try? self.jsonDecoder.decode(HistoricalDataResponse.self, from: mockResponse) else {
                    competionHandler(.failure(.parsing))
                    return
                }
                competionHandler(.success(response))
            case (nil, nil):
                competionHandler(.failure(.inconsistentBehavior))
            }
        }
        hourDataTask?.resume()
    }
    
    private func fetchDayData(assets: String,  _ competionHandler: @escaping ((Result<HistoricalDataResponse, NetworkError>) -> Void)) {
        guard dayDataTask?.state != .running else { return }
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD,EUR") else {
            competionHandler(.failure(.networkError))
            return
        }
        dayDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            switch (data, error) {
            case (_, .some):
                competionHandler(.failure(.networkError))
            case let (.some(data), nil):
                guard let mockResponse = dayDataResponse.data(using: .utf8) else {
                    return
                }
                guard let response = try? self.jsonDecoder.decode(HistoricalDataResponse.self, from: mockResponse) else {
                    competionHandler(.failure(.parsing))
                    return
                }
                competionHandler(.success(response))
            case (nil, nil):
                competionHandler(.failure(.inconsistentBehavior))
            }
        }
        dayDataTask?.resume()
    }
    
    private func fetchWeekData(assets: String,  _ competionHandler: @escaping ((Result<HistoricalDataResponse, NetworkError>) -> Void)) {
        guard weekDataTask?.state != .running else { return }
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD,EUR") else {
            competionHandler(.failure(.networkError))
            return
        }
        weekDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            switch (data, error) {
            case (_, .some):
                competionHandler(.failure(.networkError))
            case let (.some(data), nil):
                guard let mockResponse = weekDataResponse.data(using: .utf8) else {
                    return
                }
                guard let response = try? self.jsonDecoder.decode(HistoricalDataResponse.self, from: mockResponse) else {
                    competionHandler(.failure(.parsing))
                    return
                }
                competionHandler(.success(response))
            case (nil, nil):
                competionHandler(.failure(.inconsistentBehavior))
            }
        }
        weekDataTask?.resume()
    }
    
    private func fetchMonthData(assets: String,  _ competionHandler: @escaping ((Result<HistoricalDataResponse, NetworkError>) -> Void)) {
        guard monthDataTask?.state != .running else { return }
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD,EUR") else {
            competionHandler(.failure(.networkError))
            return
        }
        monthDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            switch (data, error) {
            case (_, .some):
                competionHandler(.failure(.networkError))
            case let (.some(data), nil):
                guard let mockResponse = monthDataResponse.data(using: .utf8) else {
                    return
                }
                guard let response = try? self.jsonDecoder.decode(HistoricalDataResponse.self, from: mockResponse) else {
                    competionHandler(.failure(.parsing))
                    return
                }
                competionHandler(.success(response))
            case (nil, nil):
                competionHandler(.failure(.inconsistentBehavior))
            }
        }
        monthDataTask?.resume()
    }
    
    private func fetchYearData(assets: String,  _ competionHandler: @escaping ((Result<HistoricalDataResponse, NetworkError>) -> Void)) {
        guard yearDataTask?.state != .running else { return }
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD,EUR") else {
            competionHandler(.failure(.networkError))
            return
        }
        yearDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            switch (data, error) {
            case (_, .some):
                competionHandler(.failure(.networkError))
            case let (.some(data), nil):
                guard let mockResponse = yearDataResponse.data(using: .utf8) else {
                    return
                }
                guard let response = try? self.jsonDecoder.decode(HistoricalDataResponse.self, from: mockResponse) else {
                    competionHandler(.failure(.parsing))
                    return
                }
                competionHandler(.success(response))
            case (nil, nil):
                competionHandler(.failure(.inconsistentBehavior))
            }
        }
        yearDataTask?.resume()
    }
}
