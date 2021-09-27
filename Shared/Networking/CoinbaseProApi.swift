//
//  CoinbaseProApi.swift
//  Portal
//
//  Created by Farid on 16/05/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation
import Combine

struct CoinbaseProApi {
    private let api = Router<CoinbaseProPrivateApi>()
    
    func fetchBalance(credentials: ExchangeCredentials) -> AnyPublisher<[ExchangeBalanceModel], NetworkError>? {
        api
            .dispatch(.balances(credentials: credentials))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: [CoinbaseBalancesResponse].self, decoder: JSONDecoder())
            .mapError { error in
                NetworkError.error(error.localizedDescription)
            }
            .map({ response in
                response.filter{$0.balance.doubleValue > 0.0}.map { balance in
                    ExchangeBalanceModel(balance)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func orders(credentials: ExchangeCredentials, symbol: String) -> AnyPublisher<[ExchangeOrderModel]?, NetworkError>? {
         api
            .dispatch(.orders(credentials: credentials, symbol: symbol))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: [CoinbaseOrder].self, decoder: JSONDecoder())
            .mapError { error in
                NetworkError.error(error.localizedDescription)
            }
            .map{ $0.filter{$0.status != "rejected"}.map{ExchangeOrderModel.init(order: $0)} }
            .eraseToAnyPublisher()
    }
    
    func placeOrder(credentials: ExchangeCredentials, type: String, side: String, symbol: String, price: Double, quantity: Double) -> AnyPublisher<CoinbaseOrder, NetworkError>? {
        api
            .dispatch(.placeOrder(credentials: credentials, symbol: symbol, type: type, side: side, price: price, quantity: quantity))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: CoinbaseOrder.self, decoder: JSONDecoder())
            .mapError { error in
                NetworkError.error(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func cancelOrder(credentials: ExchangeCredentials, symbol: String, orderID: String) -> AnyPublisher<Data, NetworkError>? {
        api
            .dispatch(.cancelOrder(credentials: credentials, symbol: symbol, orderID: orderID))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .mapError { error in
                NetworkError.error(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func depositAddress(credentials: ExchangeCredentials, symbol: String) {//, completion: @escaping (_ address: String?, _ error: String?) -> ()
//        api.request(.coinbaseAccounts(credentials: credentials)) { (data, response, error) in
//            let errorTitle = "[\(credentials.name.firstUppercased)] getting deposit address error:"
//
//            if error != nil {
//                completion(nil, "\(errorTitle) \(error!.localizedDescription)")
//            }
//            guard let responseData = data else {
//                completion(nil, "\(errorTitle) \(NetworkResponse.noData.rawValue)")
//                return
//            }
//            var depositAccount: CoinbaseAccount?
//            do {
//                let allAccounts = try JSONDecoder().decode([CoinbaseAccount].self, from: responseData)
//                depositAccount = allAccounts.filter{$0.active && $0.currency == symbol}.first
//            } catch {
//                print("\(#function) error: \(error)")
//                let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String : Any]
//                guard let message = json?["message"] as? String else {
//                    completion(nil, "\(errorTitle) \(error.localizedDescription)")
//                    return
//                }
//                completion(nil, "\(errorTitle) \(message)")
//            }
//            guard let accountID = depositAccount?.id else {
//                completion(nil, "Coinbase deposit address for \(symbol) is missing")
//                return
//            }
//            self.api.request(.depositAddress(credentials: credentials, id: accountID)) { (data, response, error) in
//                if error != nil {
//                    completion(nil, "\(errorTitle) \(error!.localizedDescription)")
//                }
//                guard let responseData = data else {
//                    completion(nil, "\(errorTitle) \(NetworkResponse.noData.rawValue)")
//                    return
//                }
//                let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String : Any]
//                guard let message = json?["message"] as? String else {
//                    completion(nil, "\(errorTitle)")
//                    return
//                }
//                completion(nil, "\(errorTitle) \(message)")
//            }
//        }
    }
    func withdraw(credentials: ExchangeCredentials, symbol: String, amount: Double, address: String) -> AnyPublisher<Bool, NetworkError>? {
        api
            .dispatch(.withdraw(credentials: credentials, asset: symbol, address: address, amount: amount))?
            .tryMap({ data, response in
                try handleResponse(data: data, response: response, exchangeName: credentials.name.firstUppercased)
            })
            .decode(type: CoinbaseWithdrawResponse.self, decoder: JSONDecoder())
            .mapError { error in
                NetworkError.error(error.localizedDescription)
            }
            .map({ data in
                return true
            })
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
        let errorTitle = "[\(exchangeName)] error:"
        if let code = json["message"] as? String {
            throw NetworkError.error("\(errorTitle) \(code)")
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
