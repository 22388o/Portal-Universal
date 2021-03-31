//
//  IChartDataProvider.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IChartDataProvider {
    func values(timeframe: Timeframe, points: [MarketSnapshot]) -> [Double]
}

extension IChartDataProvider {
    func values(timeframe: Timeframe, points: [MarketSnapshot]) -> [Double] {
    //        let maxIndex = points.count
    //        let calendar = Calendar.current
    //        let currentDate = currentDateInUserTimeZone()
            switch timeframe {
            case .hour:
                return points.enumerated().map{ (index, point) in
    //                let timestamp = calendar.date(byAdding: .minute, value: index - maxIndex, to: currentDate)?.timeIntervalSince1970
                    return point.close //* balance(at: timestamp)
                }
            case .day, .week:
                return points.enumerated().map{ (index, point) in
    //                let timestamp = calendar.date(byAdding: .hour, value: index - maxIndex, to: currentDate)?.timeIntervalSince1970
                    return point.close //* balance(at: timestamp)
                }
            case .month, .year:
                return points.enumerated().map{ (index, point) in
    //                let timestamp = calendar.date(byAdding: .day, value: index - maxIndex, to: currentDate)?.timeIntervalSince1970
                    return point.close //* balance(at: timestamp)
                }
            case .allTime:
    //            let timestamp = Date().timeIntervalSince1970
                return points.enumerated().map{ (index, point) in point.close /* balance(at: timestamp)*/ }
            }
        }
}
