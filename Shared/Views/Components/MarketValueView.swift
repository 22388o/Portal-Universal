//
//  MarketValueView.swift
//  Portal
//
//  Created by Farid on 11.04.2021.
//

import SwiftUI
import Charts

struct MarketValueView: View {
    @Binding var timeframe: Timeframe
    @Binding var valueCurrencyViewSate: ValueCurrencySwitchState
    @Binding var fiatCurrency: FiatCurrency
    
    let totalValue: String
    let change: String
    let high: String
    let low: String
    let chartDataEntries: [ChartDataEntry]
    
    let type: AssetMarketValueViewType

    var body: some View {
        VStack {
            TimeframeButtonsView(type: type, timeframe: $timeframe)
                .offset(x: -2)
                .padding(.top)
            
            VStack {
                VStack(spacing: 4) {
                    Text(type == .asset ? "Current value" : "Total value")
                        .font(Font.mainFont(size: 12))
                        .foregroundColor(type == .asset ? Color.coinViewRouteButtonActive : Color.white.opacity(0.5))
                        .padding(.vertical, 6)
                    
                    ValueCurrencySwitchView(state: $valueCurrencyViewSate, fiatCurrency: fiatCurrency, type: type)
                    
                    HStack {
                        Button(action: {
                            previousCurrency()
                        }) {
                            Image("arrowLeftLight")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Text(totalValue)
                            .lineLimit(1)
                            .font(Font.mainFont(size: 26))
                            .foregroundColor(type == .asset ? Color.assetValueLabel : Color.white.opacity(0.8))
                        
                        Spacer()
                        
                        Button(action: {
                            nextCurrency()
                        }) {
                            Image("arrowRightLight")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 6)
                    
                    Text(change)
                        .font(Font.mainFont(size: 15))
                        .foregroundColor(Color(red: 228.0/255.0, green: 136.0/255.0, blue: 37.0/255.0))
                }
            }
            
            LineChartRepresentable(chartDataEntries: chartDataEntries)
                .frame(height: 106)
                .padding(.top, 20)
            
            HStack(spacing: 40) {
                VStack(spacing: 10) {
                    Text("High")
                        .font(Font.mainFont())
                        .foregroundColor(type == .asset ? Color.lightActiveLabel.opacity(0.5) : Color.white.opacity(0.5))
                    Text(high)
                        .font(Font.mainFont(size: 15))
                        .foregroundColor(type == .asset ? Color.lightActiveLabel.opacity(0.8) : Color.white.opacity(0.8))
                }
                
                VStack(spacing: 10) {
                    Text("Low")
                        .font(Font.mainFont())
                        .foregroundColor(type == .asset ? Color.lightActiveLabel.opacity(0.5) : Color.white.opacity(0.5))
                    Text(low)
                        .font(Font.mainFont(size: 15))
                        .foregroundColor(type == .asset ? Color.lightActiveLabel.opacity(0.8) : Color.white.opacity(0.8))

                }
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func previousCurrency() {
        switch valueCurrencyViewSate {
        case .fiat:
            valueCurrencyViewSate = .eth
        case .btc:
            valueCurrencyViewSate = .fiat
        case .eth:
            valueCurrencyViewSate = .btc
        }
    }
    private func nextCurrency() {
        switch valueCurrencyViewSate {
        case .fiat:
            valueCurrencyViewSate = .btc
        case .btc:
            valueCurrencyViewSate = .eth
        case .eth:
            valueCurrencyViewSate = .fiat
        }
    }
}

struct AssetMarketValueView_Previews: PreviewProvider {
    static var previews: some View {
        MarketValueView(
            timeframe: .constant(.day),
            valueCurrencyViewSate: .constant(.fiat),
            fiatCurrency: .constant(USD),
            totalValue: "$2836.211",
            change: "-$423 (3.46%)",
            high: "$0.0",
            low: "$0.0",
            chartDataEntries: [
                ChartDataEntry(x: 0.0, y: 7176.99),
                ChartDataEntry(x: 1.0, y: 7156.99),
                ChartDataEntry(x: 2.0, y: 7140.92),
                ChartDataEntry(x: 3.0, y: 7170.18),
                ChartDataEntry(x: 4.0, y: 7166.14),
                ChartDataEntry(x: 5.0, y: 7199.79),
                ChartDataEntry(x: 6.0, y: 7199.97),
                ChartDataEntry(x: 7.0, y: 7201.38),
                ChartDataEntry(x: 8.0, y: 7173.5),
                ChartDataEntry(x: 9.0, y: 7202.12),
                ChartDataEntry(x: 10.0, y: 7212.33),
                ChartDataEntry(x: 11.0, y: 7213.47),
                ChartDataEntry(x: 12.0, y: 7224.86),
                ChartDataEntry(x: 13.0, y: 7218.46),
                ChartDataEntry(x: 14.0, y: 7260.58),
                ChartDataEntry(x: 15.0, y: 7212.6),
                ChartDataEntry(x: 16.0, y: 7204.59),
                ChartDataEntry(x: 17.0, y: 7199.39),
                ChartDataEntry(x: 18.0, y: 7209.57),
                ChartDataEntry(x: 19.0, y: 7205.44),
                ChartDataEntry(x: 20.0, y: 7217.03),
                ChartDataEntry(x: 21.0, y: 7229.49),
                ChartDataEntry(x: 22.0, y: 7233.47),
                ChartDataEntry(x: 23.0, y: 7234.02)
            ],
            type: .asset
        )
        .frame(width: 304)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
//        .background(
//            ZStack {
//                Color.portalGradientBackground
//                Color.black.opacity(0.58)
//            }
//        )
    }
}
