//
//  Asset.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

final class TxProvider: ITxProvider {
    let coin: Coin
    let kit: ICoinKit
    
    init(coin: Coin, kit: ICoinKit) {
        self.coin = coin
        self.kit = kit
    }
}
protocol ITxProvider {}

final class Asset: IAsset {
    var id: UUID
    var coin: Coin
    var kit: ICoinKit
    var balanceProvider: IBalanceProvider
    var chartDataProvider: IChartDataProvider
    var marketChangeProvider: IMarketChangeProvider
    var qrCodeProvider: IQRCodeProvider

    init(coin: Coin, data: Data = Data(), kit: ICoinKit = MockCoinKit()) {
        self.id = UUID()
        self.coin = coin
        self.kit = kit
        
        self.balanceProvider = BalanceProvider(coin: coin, kit: kit)
        self.chartDataProvider = ChartDataProvider()
        self.marketChangeProvider = MarketChangeProvider()
        self.qrCodeProvider = QRCodeProvider()
    }
    
    static func bitcoin() -> IAsset {
        Asset(coin: Coin.bitcoin())
    }
}
