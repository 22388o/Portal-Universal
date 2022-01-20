//
//  IFiatCurrenciesUpdater.swift
//  Portal
//
//  Created by farid on 1/20/22.
//

import Foundation
import Combine

protocol IFiatCurrenciesUpdater {
    var onFiatCurrenciesUpdate: PassthroughSubject<[FiatCurrency], Never> { get }
}
