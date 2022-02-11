//
//  MockedFiatCurrenciesUpdater.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/24/22.
//

import Combine
@testable import Portal

struct MockedFiatCurrenciesUpdater: IFiatCurrenciesUpdater {
    var onFiatCurrenciesUpdate = PassthroughSubject<[FiatCurrency], Never>()
}
