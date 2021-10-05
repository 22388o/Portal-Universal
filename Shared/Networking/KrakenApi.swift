//
//  KrakenApi.swift
//  Portal
//
//  Created by Manoj Duggirala on 06/17/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation

public enum OrderSide: String {
    case sell, buy
    
    var description: String {
        switch self {
        case .buy:
            return "Buy"
        case .sell:
            return "Sell"
        }
    }
}
public enum OrderType: String {
    case market, limit
}


struct KrakenApi {
    private let api = Router<KrakenPrivateApi>()
    
    func fetchBalance(credentials: ExchangeCredentials) { //, completion: @escaping (_ balances: [ExchangeBalanceModel], _ error: String?) -> ()
        var kbalances = [ExchangeBalanceModel]()
        var assetlist = [String:String]()
        
//        self.api.request(.assets(credentials: credentials)) { (data, response, error) in
//            guard let responseData = data else {
//                print(NetworkResponse.noData.rawValue)
//                return
//            }
//            do {
////                print(responseData.printJSON())
//                let response = try JSONDecoder().decode(KrakenAssetResponse.self, from: responseData)
//                for (key, value) in response.assetData as [String:KrakenAsset] {
//                    let asset = key
//                    var altname = value.altname
//                    if altname == "XBT" { altname = "BTC"}
//                    assetlist[asset] = altname
//                }
//
//                self.api.request(.balances(credentials: credentials)) { (data, response, error) in
//                    if error != nil {
//                        completion(kbalances, "\(#function) error: \(error!.localizedDescription)")
//                    }
//                    guard let responseData = data else {
//                        print(NetworkResponse.noData.rawValue)
//                        completion(kbalances, nil)
//                        return
//                    }
//                    do {
////                        print(responseData.printJSON())
//                        let response = try JSONDecoder().decode(KrakenBalancesResponse.self, from: responseData)
//                        if response.error.isEmpty {
//                            guard let balances = response.balancesData else {
//                                completion(kbalances, nil)
//                                return
//                            }
//                            for assets in balances {
//                                let name = assets.key
//                                let realname = assetlist[name]
//                                let model = KrakenBalance(asset:realname!, free:Double(assets.value)!, locked:0)
//                                kbalances.append(ExchangeBalanceModel(model))
//                            }
//                            completion(kbalances, nil)
//                        } else {
//                            completion(kbalances, self.handleError(error: response.error))
//                        }
//                    } catch {
//                        print("\(#function) error: \(error)")
//                        completion(kbalances, "Fetching kraken balances error")
//                    }
//                }
//
//            } catch {
//                print("\(#function) error: \(error)")
//            }
//        }
    }
    
    func orders(credentials: ExchangeCredentials) {//completion: @escaping (_ orders: [ExchangeOrderModel]?, _ error: String?) -> ()
//        api.request(.openOrders(credentials: credentials)) { (data, response, error) in
//            if error != nil {
//                completion(nil, "\(#function) error: \(error!.localizedDescription)")
//            }
//            guard let responseData = data else {
//                completion(nil, NetworkResponse.noData.rawValue)
//                return
//            }
//            do {
////                print(responseData.printJSON())
//                let response = try JSONDecoder().decode(KrakenOrdersResponse.self, from: responseData)
//                var orders = [ExchangeOrderModel]()
//                if response.error.isEmpty {
//                    let Ordersdict = response.orders["open"]
//                    for (key, value) in Ordersdict! {
////                        let pair = value.descr.pair
////                        if (pair==symbol) {
//                            orders.append(ExchangeOrderModel.init(order:value, txid:key))
////                        }
//                    }
//                    completion(orders, nil)
//                } else {
//                    completion(nil, self.handleError(error: response.error))
//                }
//            } catch {
//                print("\(#function) error: \(error)")
//                completion(nil, "Fetching kraken orders error")
//            }
//        }
    }
    
    func ordersHistory(credentials: ExchangeCredentials, symbol: String) { //, completion: @escaping (_ orders: [ExchangeOrderModel]?, _ error: String?) -> ()
//        api.request(.orders(credentials: credentials)) { (data, response, error) in
//            if error != nil {
//                completion(nil, "\(#function) error: \(error!.localizedDescription)")
//            }
//            guard let responseData = data else {
//                completion(nil, NetworkResponse.noData.rawValue)
//                return
//            }
//            do {
//                let response = try JSONDecoder().decode(KrakenOrderHistoryResponse.self, from: responseData)
//                var orders = [ExchangeOrderModel]()
//                if response.error.isEmpty {
//                    let Ordersdict = response.historyData.trades
//
//                    for (_, value) in Ordersdict {
//                        let pair = value.pair
//                        if pair == symbol {
//                            orders.append(ExchangeOrderModel.init(order:value))
//                        }
//                    }
//                    completion(orders, nil)
//                } else {
//                    completion(nil, self.handleError(error: response.error))
//                }
//            } catch {
//                print("\(#function) error: \(error)")
//                completion(nil, "Fetching kraken orders error")
//            }
//        }
    }
    
    func placeOrder(credentials: ExchangeCredentials, type: OrderType, side: OrderSide, symbol: String, price: Double, quantity: Double) { //, completion: @escaping (_ error: String?) -> ()
        let rounded_price = price.rounded(toPlaces: 5)
//        api.request(.placeOrder(credentials: credentials, symbol: symbol, price: rounded_price, quantity: quantity, ordertype: type.rawValue, orderside: side.rawValue)) { (data, response, error) in
//            if error != nil {
//                completion("Kraken error: \(error!.localizedDescription)")
//            }
//            guard let responseData = data else {
//                completion(NetworkResponse.noData.rawValue)
//                return
//            }
//            do {
//                let response = try JSONDecoder().decode(KrakenPlaceOrderResponse.self, from: responseData)
//                if response.error.isEmpty {
//                    completion(nil)
//                } else {
//                    completion(self.handleError(error: response.error))
//                }
//            } catch {
//                print("\(#function) error: \(error)")
//                completion("Place order error :/")
//            }
//        }
    }

    func cancelOrder(credentials: ExchangeCredentials, symbol: String, orderID: String) { //, completion: @escaping (_ error: String?) -> ()
//        api.request(.cancelOrder(credentials: credentials, orderID: orderID)) { (data, response, error) in
//            if error != nil {
//                completion("Kraken error: \(error!.localizedDescription)")
//            }
//            guard let responseData = data else {
//                completion(NetworkResponse.noData.rawValue)
//                return
//            }
//            do {
//                let response = try JSONDecoder().decode(KrakenCancelOrderResponse.self, from: responseData)
//                if response.error.isEmpty {
//                    completion(nil)
//                } else {
//                    completion(self.handleError(error: response.error))
//                }
//            } catch {
//                print("\(#function) error: \(error)")
//                completion("Cancel order error :/")
//            }
//        }
    }

    func withdraw(credentials: ExchangeCredentials, symbol: String, amount: Double, address: String, key: String) { //, completion: @escaping (_ error: String?) -> ()
//        api.request(.withdraw(credentials: credentials, asset: symbol, amount: amount, key: key)) { (data, response, error) in
//            if error != nil {
//                completion("Kraken error: \(error!.localizedDescription)")
//            }
//            guard let responseData = data else {
//                completion(NetworkResponse.noData.rawValue)
//                return
//            }
//            do {
//                print(responseData.printJSON())
//                let response = try JSONDecoder().decode(KrakenWithdrawResponse.self, from: responseData)
//                if response.error.isEmpty {
//                    completion(nil)
//                } else {
//                    completion(self.handleError(error: response.error))
//                }
//            } catch {
//                print("\(#function) error: \(error)")
//                completion("Withdraw error :/")
//            }
//        }
    }

    func depositAddress(credentials: ExchangeCredentials, symbol: String) { //, completion: @escaping (_ address: String?, _ error: String?) -> ()
        var method = ""

//        self.api.request(.depositMethods(credentials: credentials, asset: symbol)) { (data, response, error) in
//            guard let responseData = data else {
//                print(NetworkResponse.noData.rawValue)
//                return
//            }
//            do {
//                let response = try JSONDecoder().decode(KrakenDepositMethodsResponse.self, from: responseData)
//                if response.error.isEmpty {
//                    let methodata = response.methodData
//                    if (methodata?.count)!>0{
//                        method = (response.methodData?[0].method)!
//                        self.api.request(.depositAddress(credentials: credentials, asset: symbol, method:method)) { (data, response, error) in
//                            if error != nil {
//                                completion(nil,"Kraken error: \(error!.localizedDescription)")
//                            }
//                            guard let responseData = data else {
//                                completion(nil, NetworkResponse.noData.rawValue)
//                                return
//                            }
//                            do {
//
//                                let response = try JSONDecoder().decode(KrakenDepositAddressResponse.self, from: responseData)
//                                if response.error.isEmpty {
//                                    let addressdata = response.addressData
//                                    if (addressdata?.count)!>0{
//                                        completion(response.addressData![0].address, nil)
//                                    }
//                                } else {
//                                    completion(nil, self.handleError(error: response.error))
//                                }
//                            } catch {
//                                print("\(#function) error: \(error)")
//                                completion(nil, nil)
//                            }
//                        }
//                    }
//                                        
//                }
//            } catch {
//                print("\(#function) error: \(error)")
//            }
//        }
        

    }
    
    //MARK:- TODO: Handle errors based on service
    fileprivate func handleError(error:[String]) -> String{
        var error_string = "Kraken API returned an unknown error"
        if error.count > 0 {
            error_string = error.joined(separator: ",")
        }
        return error_string
    }

}
