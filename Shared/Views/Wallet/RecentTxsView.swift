//
//  RecentTxsView.swift
//  Portal
//
//  Created by Farid on 19.04.2021.
//

import SwiftUI

struct RecentTxsView: View {
    let coin: Coin
    @Binding var showAllTxs: Bool
    
    @FetchRequest(
        entity: DBTx.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \DBTx.timestamp, ascending: false),
        ]
//        predicate: NSPredicate(format: "coin == %@", code)
    ) private var allTxs: FetchedResults<DBTx>
    
    var body: some View {
        if allTxs.filter({$0.coin == coin.code}).isEmpty {
            VStack {
                Spacer()
                Text("There is no transactions yet")
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.coinViewRouteButtonActive)
                Spacer()
            }
        } else {
            VStack {
                HStack {
                    Text("Recent activity")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                }
                .padding(.top)
                
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(allTxs.filter {$0.coin == coin.code}) { tx in
                            HStack(spacing: 8) {
                                Text("Sent \(tx.amount ?? 0) \(tx.coin ?? "?")")
                                    .frame(width: 120)
                                    .font(.mainFont(size: 12))
                                    .foregroundColor(Color.coinViewRouteButtonActive)
                                Spacer()
                                Text("\(tx.timestamp ?? Date())")
                                    .lineLimit(1)
                                    .font(.mainFont(size: 12))
                                    .foregroundColor(Color.coinViewRouteButtonInactive)
                                Spacer()
                            }
                            .frame(height: 40)
                        }
                        .font(.mainFont(size: 12))
                    }
                }
                .frame(width: 256)
                
                PButton(label: "See all transactions", width: 256, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        showAllTxs.toggle()
                    }
                }
                .padding(.bottom, 41)
            }
        }
    }
}

struct RecentTxsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentTxsView(coin: Coin.bitcoin(), showAllTxs: .constant(false))
    }
}
