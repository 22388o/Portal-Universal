//
//  IAsset.swift
//  Portal
//
//  Created by Farid on 18.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IAsset {
    var id: UUID { get }
    var marketDataProvider: IMarketDataProvider { get }
//    var viewModel: AssetViewModel { get }
    var coin: Coin { get }
    var kit: ICoinKit { get }
    var chartDataProvider: IChartDataProvider { get }
    var balanceProvider: IBalanceProvider { get }
    var marketChangeProvider: IMarketChangeProvider { get }
    var qrCodeProvider: IQRCodeProvider { get }
}
