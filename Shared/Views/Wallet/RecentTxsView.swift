//
//  RecentTxsView.swift
//  Portal
//
//  Created by Farid on 19.04.2021.
//

import SwiftUI

struct RecentTxsView: View {
    @Binding var showAllTxs: Bool
    @ObservedObject private var viewModel: TxsViewModel
    
    init(asset: IAsset, showAllTxs: Binding<Bool>) {
        self._showAllTxs = showAllTxs
        self.viewModel = .init(asset: asset)
    }
    
    var body: some View {
        if viewModel.txs.isEmpty {
            VStack {
                Spacer()
                Text("There is no transactions yet")
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.coinViewRouteButtonActive)
                Spacer()
            }
        } else {
            VStack(spacing: 0) {
                Text("Recent activity")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.coinViewRouteButtonActive)
                    .padding(.vertical)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Rectangle()
                            .fill(Color.exchangerFieldBorder)
                            .frame(height: 1)
                        
                        ForEach(viewModel.txs, id: \.uid) { tx in
                            VStack(spacing: 4) {
                                HStack(spacing: 8) {
                                    VStack {
                                        Text(viewModel.title(tx: tx))
                                    }
                                    .font(.mainFont(size: 12))
                                    .foregroundColor(Color.coinViewRouteButtonActive)
                                    Spacer()
                                    Text(viewModel.date(tx: tx))
                                        .lineLimit(1)
                                        .font(.mainFont(size: 12))
                                        .foregroundColor(Color.coinViewRouteButtonInactive)
                                }
                                
                                HStack {
                                    Text(viewModel.confimations(tx: tx))
                                        .font(.mainFont(size: 12))
                                        .foregroundColor(Color.coinViewRouteButtonInactive)
                                    Spacer()
                                }
                            }
                            .frame(height: 56)
                            
                            Rectangle()
                                .fill(Color.exchangerFieldBorder)
                                .frame(height: 1)
                        }
                    }
                }
                .frame(width: 256)
                
                PButton(label: "See all transactions", width: 256, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        showAllTxs.toggle()
                    }
                }
                .padding(.bottom, 41)
                .padding(.top, 20)
            }
        }
    }
}

struct RecentTxsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentTxsView(asset: Asset.bitcoin(), showAllTxs: .constant(false))
    }
}
