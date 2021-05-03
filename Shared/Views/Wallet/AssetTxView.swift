//
//  AssetTxView.swift
//  Portal
//
//  Created by Farid on 19.04.2021.
//

import SwiftUI

struct AssetTxView: View {
    let asset: IAsset
    @Binding var presented: Bool
    @State var selectedTx: DBTx?
    
    @FetchRequest(
        entity: DBTx.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \DBTx.timestamp, ascending: false),
        ]
    ) private var allTxs: FetchedResults<DBTx>
    
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
                    PButton(label: "All Transaction", width: 132, height: 32, fontSize: 12, enabled: true) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTx = nil
                        }
                    }
//                    .transition(.scale)
                }
                Spacer()
                PButton(label: "Done", width: 73, height: 32, fontSize: 12, enabled: true) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        presented.toggle()
                    }
                }
            }
            .padding([.top, .horizontal], 16)
            
            if let tx = selectedTx {
                VStack(spacing: 0) {
                    Text("Transaction Details")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.bottom, 8)
                    
                    Text("Sent \(tx.amount ?? 0) \(asset.coin.code)")
                        .font(.mainFont(size: 23))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.bottom, 8)
                    
                    Text("\(tx.timestamp ?? Date())")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.bottom, 13)
                    
                    PButton(label: "View transaction in block explorer", width: 230, height: 32, fontSize: 12, enabled: true, action: {
            
                    })
                    .padding(.bottom, 34)
                    
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .fill(Color.exchangerFieldBorder)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading) {
                                Text("From")
                                Text("1245acUTDKGirRLA4Zv9Q5KNAmDBYmoibM")
                            }
                            VStack(alignment: .leading) {
                                Text("To")
                                Text("\(tx.receiverAddress ?? "Unknown")")
                            }
                            VStack(alignment: .leading) {
                                Text("Hash")
                                Text("26b4c6139f66d03ae0fcc8c357a176c22dcefb6626d6a123f2d94a279c057d35")
                            }
                            VStack(alignment: .leading) {
                                Text("Status")
                                Text("• Done")
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Memo")
                                Text("\(tx.memo ?? String())")
                            }
                        }
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.horizontal, 24)
                        .padding(.vertical)
                    }
                    .padding([.bottom, .horizontal], 4)
                }
                .padding(.top, 57)
                .transition(.identity)
            } else {
                VStack(spacing: 0) {
                    Text("\(asset.coin.code) Transactions")
                        .font(.mainFont(size: 23))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.bottom, 8)
                    Text("You have \(asset.balanceProvider.balanceString) \(asset.coin.code) (\(asset.balanceProvider.totalValueString))")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.bottom, 34)
                    
                    HStack(spacing: 30) {
                        Text("All")
                        Text("Sent")
                        Text("Received")
                        Spacer()
                    }
                    .font(.mainFont(size: 13))
                    .foregroundColor(Color.coinViewRouteButtonActive)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 8)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.exchangerFieldBorder)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                Spacer().frame(height: 8)
                                
                                ForEach(allTxs.filter {$0.coin == asset.coin.code}) { tx in
                                    HStack(spacing: 0) {
                                        Text("• Done")
                                        Text("\(tx.amount ?? 0) \(tx.coin ?? "?")")
                                            .frame(width: 85)
                                            .padding(.leading, 40)
                                        Text("\(tx.receiverAddress ?? "unknown address")")
                                            .lineLimit(1)
                                            .frame(width: 201)
                                            .padding(.leading, 32)
                                        Text("\(tx.timestamp ?? Date())")
                                            .frame(width: 80)
                                            .lineLimit(1)
                                            .padding(.leading, 32)
                                    }
                                    .foregroundColor(Color.coinViewRouteButtonActive)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedTx = tx
                                        }
                                    }
                                }
                                .font(.mainFont(size: 12))
                            }
                        }
                            
                    }
                    .padding([.bottom, .horizontal], 4)
                }
                .padding(.top, 57)
                .transition(.identity)
            }
        }
        .frame(width: 576, height: 662)
    }
}

struct AssetTxView_Previews: PreviewProvider {
    static var previews: some View {
        AssetTxView(asset: Asset.bitcoin(), presented: .constant(false))
            .frame(width: 576, height: 662)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
