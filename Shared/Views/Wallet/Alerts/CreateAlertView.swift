//
//  CreateAlertView.swift
//  Portal
//
//  Created by Farid on 03.05.2021.
//

import SwiftUI

struct CreateAlertView: View {
    let asset: IAsset
    @Binding var presented: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.7), lineWidth: 8)
                )

            
            CoinImageView(size: 64, url: asset.coin.icon)
                .background(Color.white)
                .cornerRadius(32)
                .offset(y: -32)
            
            HStack {
                Spacer()
                PButton(bgColor: Color.doneButtonBg, label: "Done", width: 73, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        presented.toggle()
                    }
                }
            }
            .padding([.top, .trailing], 16)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack {
                        Text("Alerts for \(asset.coin.code)")
                            .font(.mainFont(size: 23))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text("Don’t miss out on important changes! Set yourself alerts so that you’re\naware of market price changes and make smart decisions, on time.")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                    }
                    HStack {
                        CoinImageView(size: 64, url: asset.coin.icon, placeholderForegroundColor: .black)
                            .background(Color.white)
                            .cornerRadius(32)
                        Text("1.00 \(asset.coin.code) is worth $\(/*asset.balanceProvider.price*/0)")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                    }
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                                
                VStack(spacing: 23) {
//                    ExchangerView(viewModel: viewModel.exchangerViewModel)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a custom alert")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)

                        HStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.exchangerFieldBorder, lineWidth: 1)
                                )
                                .frame(width: 312, height: 48)
                            HStack(spacing: 8) {
                                FiatCurrencyView(
                                    size: 24,
                                    state: .constant(.fiat),
                                    currency: .constant(.fiat(USD))
                                )
                                .frame(width: 24, height: 24)
                                
                                #if os(iOS)
                                TextField("", text: .constant(String()))
                                    .foregroundColor(Color.lightActiveLabel)
                                    .modifier(
                                        PlaceholderStyle(
                                            showPlaceHolder: true,
                                            placeholder: "0.0"
                                        )
                                    )
                                    .frame(height: 20)
                                    .keyboardType(.numberPad)
                                #else
                                TextField("", text: .constant(String()))
                                    .colorMultiply(.lightInactiveLabel)
                                    .foregroundColor(Color.lightActiveLabel)
                                    .modifier(
                                        PlaceholderStyle(
                                            showPlaceHolder: true,
                                            placeholder: "0.0"
                                        )
                                    )
                                    .frame(height: 20)
                                #endif
                                
                                Text("USD")
                                    .font(Font.mainFont(size: 16))
                                    .foregroundColor(Color.lightActiveLabelNew)
                            }
                            .modifier(TextFieldModifier(cornerRadius: 26))
                            .frame(width: 224, height: 48)
                        }
                    }
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Private description / memo (optional)")
//                            .font(.mainFont(size: 12))
//                            .foregroundColor(Color.coinViewRouteButtonInactive)
//
//                        PTextField(text: .constant("Memo"), placeholder: "Enter private description or memo", upperCase: false, width: 480, height: 48)
//                    }
                }
                                
                PButton(label: "Send", width: 334, height: 48, fontSize: 14, enabled: true) {
//                    viewModel.send()
                    
                }
                .padding(.top, 16)
                .padding(.bottom, 27)
                
                HStack(spacing: 0) {
                    Text("Status")
                    Text("Amount")
                        .padding(.leading, 66)
                    Text("Sent to…")
                        .padding(.leading, 44)
                    Spacer()
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonInactive)
                .frame(width: 480)
                
                Spacer().frame(height: 8)
                
                Divider()
                
                ZStack {
                    Rectangle()
                        .fill(Color.exchangerFieldBackground)
                    
                    ScrollView {
                        LazyVStack_(alignment: .leading) {
                            Spacer().frame(height: 8)
                            
//                            ForEach(allTxs.filter {$0.coin == coin.code}) { tx in
//                                HStack(spacing: 0) {
//                                    Text("• Done")
//                                    Text("\(tx.amount ?? 0) \(tx.coin ?? "?")")
//                                        .frame(width: 85)
//                                        .padding(.leading, 40)
//                                    Text("\(tx.receiverAddress ?? "unknown address")")
//                                        .lineLimit(1)
//                                        .frame(width: 201)
//                                        .padding(.leading, 32)
//                                    Text("\(tx.timestamp ?? Date())")
//                                        .frame(width: 80)
//                                        .lineLimit(1)
//                                        .padding(.leading, 32)
//                                }
//                                .foregroundColor(.coinViewRouteButtonActive)
//                                .padding(.vertical, 2)
//                                .frame(maxWidth: .infinity)
//                            }
//                            .font(.mainFont(size: 12))
                        }
                    }
                }
                .padding([.horizontal, .bottom], 4)
            }
        }
        .frame(width: 656, height: 662)
    }
}

struct CreateAlertView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAlertView(asset: Asset.bitcoin(), presented: .constant(true))
    }
}
