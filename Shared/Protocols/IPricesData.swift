//
//  IPricesData.swift
//  Portal
//
//  Created by Farid on 16.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine

protocol IPricesData {
    var onUpdatePublisher: PassthroughSubject<PriceResponse, Never> { get }
    func updatePrices(for assets: String, _ competionHandler: @escaping ((Result<PriceResponse, NetworkError>) -> Void))
    func pause()
    func resume()
}
