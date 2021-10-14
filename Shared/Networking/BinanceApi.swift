//
//  BinanceApi.swift
//  Portal
//
//  Created by Farid on 30/04/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation
import Combine

struct BinanceApi {
    private let api = Router<BinancePrivateApi>()

    func fetchBalance(credentials: ExchangeCredentials) -> AnyPublisher<[ExchangeBalanceModel], NetworkError>? {
        api
            .dispatch(.balances(credentials: credentials))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: ExchangeBalanceInfo.self, decoder: JSONDecoder())
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .map{ $0.balances }
            .eraseToAnyPublisher()
    }
    
    func orders(credentials: ExchangeCredentials, symbol: String) -> AnyPublisher<[ExchangeOrderModel]?, NetworkError>? {
        let symbol = symbol.replacingOccurrences(of: "/", with: "")
        return api
            .dispatch(.orders(credentials: credentials, symbol: symbol))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: [BinanceOrder].self, decoder: JSONDecoder())
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .map{ $0.reversed().map{ExchangeOrderModel.init(order: $0)} }
            .eraseToAnyPublisher()
    }
    
    func openOrders(credentials: ExchangeCredentials) -> AnyPublisher<[ExchangeOrderModel]?, NetworkError>? {
        api
            .dispatch(.openOrders(credentials: credentials))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: [BinanceOrder].self, decoder: JSONDecoder())
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .map{ $0.reversed().map{ExchangeOrderModel.init(order: $0)} }
            .eraseToAnyPublisher()
    }
    
    func placeOrder(credentials: ExchangeCredentials, type: String, side: String, symbol: String, price: Double, quantity: Double) -> AnyPublisher<Bool, NetworkError>? {
        let symbol = symbol.replacingOccurrences(of: "/", with: "")
        
        return api
            .dispatch(.placeOrder(credentials: credentials, symbol: symbol, type: type, side: side, price: price, quantity: quantity))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: BinanceNewOrderACK.self, decoder: JSONDecoder())
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .map { order in return true }
            .eraseToAnyPublisher()
    }
    
    func cancelOrder(credentials: ExchangeCredentials, symbol: String, orderID: String) -> AnyPublisher<Data, NetworkError>? {
        let symbol = symbol.replacingOccurrences(of: "/", with: "")
        
        return api
            .dispatch(.cancelOrder(credentials: credentials, symbol: symbol, orderID: orderID))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .eraseToAnyPublisher()
    }
    
    func withdraw(credentials: ExchangeCredentials, symbol: String, amount: Double, address: String) -> AnyPublisher<Bool, NetworkError>? {
        api
            .dispatch(.withdraw(credentials: credentials, asset: symbol, address: address, amount: amount))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .map({ data in
                return true
            })
            .eraseToAnyPublisher()
    }
    
    func depositAddress(credentials: ExchangeCredentials, symbol: String) -> AnyPublisher<String, NetworkError>? {
        api
            .dispatch(.depositAddress(credentials: credentials, asset: symbol))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: DepositAddressInfo.self, decoder: JSONDecoder())
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .map{ $0.address }
            .eraseToAnyPublisher()
    }
    
    func assetsInfo(credentials: ExchangeCredentials) -> AnyPublisher<[String: BinanceAssetFeesInfo], NetworkError>? {
        api
            .dispatch(.assetDetail(creadentials: credentials))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: BinanceAssetInfo.self, decoder: JSONDecoder())
            .mapError { error in
                guard let networkError = error as? NetworkError else { return NetworkError.error("\(error)") }
                return networkError
            }
            .compactMap{ $0.assetDetail }
            .eraseToAnyPublisher()
    }
    
    private func handleResponse(data: Data, response: URLResponse, exchangeName: String) throws -> Data {
        if let response = response as? HTTPURLResponse {
            let result = handleNetworkResponse(response)
            
            switch result {
            case .success:
                return data
            case .failure(let networkFailureError):
                throw try handleFailureResponse(exchangeName: exchangeName, data: data, error: networkFailureError)
            }
        } else {
            throw NetworkError.parsingError
        }
    }
    
    private func handleFailureResponse(exchangeName: String, data: Data, error: String) throws -> NetworkError {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw NetworkError.parsingError
        }
        let errorTitle = "[\(exchangeName)]:"
        if let message = json["msg"] as? String, let code = json["code"] as? Int {
            let errorMessage = "\(errorTitle) \(message) (\(code))"
            throw NetworkError.error(errorMessage)
        } else {
            throw NetworkError.error("\(errorTitle) \(error)")
        }
    }
    
    private func handleNetworkResponse(_ response: HTTPURLResponse) -> _Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500:
            print("request failed with \(response.statusCode) error")
            return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599:
            print("request failed with \(response.statusCode) error")
            return .failure(NetworkResponse.badRequest.rawValue)
        case 600:
            print("request failed with \(response.statusCode) error")
            return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
