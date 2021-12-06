//
//  AlertsView.swift
//  Portal
//
//  Created by Farid on 03.05.2021.
//

import SwiftUI

final class AlertsViewModel: ObservableObject {
    let coin: Coin
    let alerts: [PriceAlert]
    
    init(coin: Coin, alerts: [PriceAlert]) {
        self.coin = coin
        self.alerts = alerts.reversed()
    }
}

extension AlertsViewModel {
    static func config(coin: Coin) -> AlertsViewModel {
        let storage = Portal.shared.dbStorage
        return AlertsViewModel(coin: coin, alerts: storage.alerts)
    }
}

struct AlertsView: View {
    @ObservedObject private var viewModel: AlertsViewModel
    
    init(coin: Coin) {
        self.viewModel = AlertsViewModel.config(coin: coin)
    }
    
    var body: some View {
        VStack {
            VStack {
                Image("bellIcon")
                    .resizable()
                    .frame(width: 30, height:36)
                Text("Recent changes in \(viewModel.coin.code)")
                    .font(.mainFont(size: 14))
            }
            .foregroundColor(Color.coinViewRouteButtonInactive)
            .padding(.top, 35)
            
            ScrollView(showsIndicators: false) {
                LazyVStack_(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(Color.exchangerFieldBorder)
                        .frame(height: 1)
                    
                    ForEach(viewModel.alerts) { alert in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(alert.title ?? "-")
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.coinViewRouteButtonActive)
                            Text(Date(timeIntervalSinceReferenceDate: alert.timestamp?.doubleValue ?? 0).timeAgoSinceDate(shortFormat: true))
                                .lineLimit(1)
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.coinViewRouteButtonInactive)
                        }
                        .frame(height: 56)
                        
                        Rectangle()
                            .fill(Color.exchangerFieldBorder)
                            .frame(height: 1)
                    }
                }
            }
            .frame(width: 256)
            
            PButton(label: "Manage alerts", width: 256, height: 32, fontSize: 12, enabled: true) {
                withAnimation {
                    Portal.shared.state.modalView = .createAlert
                }
            }
            .padding(.bottom, 41)
        }
    }
}

struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView(coin: Coin.bitcoin())
            .frame(width: 304, height: 480)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
