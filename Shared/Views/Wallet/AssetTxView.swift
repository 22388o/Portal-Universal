//
//  AssetTxView.swift
//  Portal
//
//  Created by Farid on 19.04.2021.
//

import SwiftUI

struct AssetTxView: View {
    private let asset: IAsset
    @Binding var presented: Bool
    @State private var selectedTx: PortalTx?
    
    @ObservedObject private var viewModel: TxsViewModel
    
    init(asset: IAsset, presented: Binding<Bool>) {
        self.asset = asset
        self.viewModel = .init(asset: asset)
        self._presented = presented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.7), lineWidth: 8)
                )
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            asset.coin.icon
                .resizable()
                .frame(width: 64, height: 64)
                .offset(y: -32)
            
            HStack {
                if selectedTx != nil {
                    PButton(bgColor: Color.doneButtonBg, label: "All Transaction", width: 132, height: 32, fontSize: 12, enabled: true) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTx = nil
                        }
                    }
                }
                Spacer()
                PButton(bgColor: Color.doneButtonBg, label: "Done", width: 73, height: 32, fontSize: 12, enabled: true) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        presented.toggle()
                    }
                }
            }
            .padding([.top, .horizontal], 16)
            
            if let tx = selectedTx {
                TxDetailsView(transaction: tx, coinCode: asset.coin.code)
                    .padding(.top, 57)
                    .transition(.identity)
            } else {
                VStack(spacing: 0) {
                    Text("\(asset.coin.code) Transactions")
                        .font(.mainFont(size: 23))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.bottom, 8)
                    HStack(spacing: 4) {
                        Text("You have")
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text(viewModel.balanceString)
                            .foregroundColor(Color.orange)
                    }
                    .font(.mainFont(size: 12))
                    .padding(.bottom, 34)
                    
                    TxSortSwitch(state: $viewModel.txSortState)
                    Divider()
                    TxHeaderView()
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.exchangerFieldBorder)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                Divider()
                                ForEach(viewModel.txs, id:\.uid) { tx in
                                    TxPreviewView(transaction: tx, coinCode: asset.coin.code) { tx in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedTx = tx
                                        }
                                    }
                                    Divider()
                                }
                            }
                        }
                            
                    }
                    .padding([.bottom, .horizontal], 4)
                }
                .padding(.top, 57)
                .transition(.identity)
            }
        }
        .allowsHitTesting(true)
        .frame(width: 776, height: 594)
    }
}

struct TxHeaderView: View {
    var body: some View {
        HStack {
            Group {
                Text("ACTION")
                
                Spacer().frame(width: 73)
                
                Text("ADDRESS")
                
                Spacer().frame(width: 173)
                
                Text("TYPE")
                
                Spacer().frame(width: 57)
                
                Text("AMOUNT")
                
                Spacer().frame(width: 54)
                
                Text("STATUS")
            }
            .font(.mainFontHeavy(size: 11))
            .foregroundColor(Color.coinViewRouteButtonInactive)
            
            Spacer()
        }
        .padding(.leading, 32)
        .frame(height: 32)
        .background(Color.exchangerFieldBorder)
        .padding(.horizontal, 4)
    }
}

struct TxDetailsView: View {
    let transaction: PortalTx
    let coinCode: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Transaction Details")
                .font(.mainFont(size: 14))
                .foregroundColor(Color.coinViewRouteButtonActive.opacity(0.6))
                .padding(.bottom, 8)
            
            Text("\(transaction.destination == .incoming ? "Received" : "Sent") \(transaction.amount.double) \(coinCode)")
                .font(.mainFont(size: 23))
                .foregroundColor(Color.coinViewRouteButtonActive)
                .padding(.bottom, 8)
            
            Text("\(transaction.date)")
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonActive.opacity(0.6))
                .padding(.bottom, 13)
            
            Button(action: {
                let urlString = "https://blockstream.info/testnet/tx/\(transaction.transactionHash)"
                if let url = URL(string: urlString) {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #elseif os(macOS)
                    NSWorkspace.shared.open(url)
                    #endif
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.exchangerFieldBorder, lineWidth: 1)
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    Text("View transaction in block explorer")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                }
            }
            .frame(width: 230, height: 32)
            .padding(.bottom, 21)
            
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.exchangerFieldBorder)
                
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("From")
                        Text("\(transaction.from ?? "Unknown")")
                    }
                    VStack(alignment: .leading) {
                        Text("To")
                        Text("\(transaction.to ?? "Unknown")")
                    }
                    VStack(alignment: .leading) {
                        Text("Hash")
                        Text("\(transaction.transactionHash)")
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Status")
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(transaction.confirmations >= 3 ? Color.orange : Color.gray)
                                .frame(width: 6, height: 6)
                            Text(transaction.confirmations >= 3 ? "Complete" : "Pending")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Block height")
                        Text("\(transaction.blockHeight ?? 0) (\(transaction.confirmations) block confirmations)")
                    }
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonActive)
                .padding(.horizontal, 24)
                .padding(.vertical)
            }
            .padding([.bottom, .horizontal], 4)
        }
    }
}

struct TxPreviewView: View {
    let transaction: PortalTx
    let coinCode: String
    let onSelect: (PortalTx) -> ()
        
    var body: some View {
        HStack(spacing: 0) {
            Group {
                HStack(spacing: 0) {
                    Text("\(transaction.destination == .incoming ? "Received from..." : "Sent to...")")
                    Spacer()
                }
                .frame(width: 100)
                
                Group {
                    switch transaction.destination {
                    case .incoming, .sentToSelf:
                        Text("\(transaction.from ?? "unknown address")")
                    case .outgoing:
                        Text("\(transaction.to ?? "unknown address")")
                    }
                }
                .lineLimit(1)
                .frame(width: 198)
                .padding(.leading, 17)
                
                Text("No label")
                    .padding(.leading, 22)
                    .frame(width: 80)
                
                Text("\(transaction.amount.double) \(coinCode)")
                    .padding(.leading, 16)
                    .frame(width: 120)
                
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(transaction.confirmations > 3 ? Color.orange : Color.gray)
                        .frame(width: 6, height: 6)
                    Text(transaction.confirmations > 3 ? "Completed" : "Pending")
                    Spacer()
                }
                .frame(width: 90)
                .padding(.leading)
                
                Text(transaction.date.timeAgoSinceDate(shortFormat: true))
                    .foregroundColor(Color.lightInactiveLabel)
                    .frame(width: 80)
                    .lineLimit(1)
                    .padding(.leading, 22)
            }
            .font(.mainFont(size: 12))
            .foregroundColor(Color.coinViewRouteButtonActive)
        }
        .padding(.horizontal, 30)
        .frame(height: 32)
        .onTapGesture {
            onSelect(transaction)
        }
    }
}

struct AssetTxView_Previews: PreviewProvider {
    static var previews: some View {
        AssetTxView(asset: Asset.bitcoin(), presented: .constant(false))
            .frame(width: 776, height: 594)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
