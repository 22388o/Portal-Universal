//
//  ManageAlertView.swift
//  Portal
//
//  Created by Farid on 03.05.2021.
//

import SwiftUI

struct ManageAlertView: View {
    @ObservedObject private var viewModel: ManageAlertViewModel
    
    init(coin: Coin) {
        viewModel = ManageAlertViewModel.config(coin: coin)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.7), lineWidth: 8)
                )
            
            CoinImageView(size: 64, url: viewModel.coin.icon)
                .background(Color.black)
                .cornerRadius(32)
                .offset(y: -32)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack {
                        Text("Alerts for \(viewModel.coin.code)")
                            .font(.mainFont(size: 23))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text("Don’t miss out on important changes! Set yourself alerts so that you’re\naware of market price changes and make smart decisions, on time.")
                            .multilineTextAlignment(.center)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                    }
                    HStack {
                        CoinImageView(size: 24, url: viewModel.coin.icon, placeholderForegroundColor: .black)
                            .background(Color.white)
                            .cornerRadius(32)
                        Text("1.00 \(viewModel.coin.code) is worth \(viewModel.worth)")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                    }
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                
                VStack(spacing: 23) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a custom alert")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                        
                        HStack {
                            AlertTypePicker(coin: viewModel.coin, type: $viewModel.type)
                                .frame(width: 312, height: 48)
                            
                            HStack(spacing: 8) {
                                switch viewModel.type {
                                case .worthMore, .worthLess:
                                    FiatCurrencyView(
                                        size: 24,
                                        currency: .constant(.fiat(USD))
                                    )
                                    .frame(width: 24, height: 24)
                                default:
                                    EmptyView()
                                }
                                
#if os(iOS)
                                TextField("", text: $viewModel.value)
                                    .foregroundColor(Color.lightActiveLabel)
                                    .modifier(
                                        PlaceholderStyle(
                                            showPlaceHolder: viewModel.value.isEmpty,
                                            placeholder: "0.0"
                                        )
                                    )
                                    .frame(height: 20)
                                    .keyboardType(.numberPad)
#else
                                TextField("", text: $viewModel.value)
                                    .colorMultiply(.lightInactiveLabel)
                                    .foregroundColor(Color.lightActiveLabel)
                                    .modifier(
                                        PlaceholderStyle(
                                            showPlaceHolder: viewModel.value.isEmpty,
                                            placeholder: "0.0"
                                        )
                                    )
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .frame(height: 20)
#endif
                                
                                switch viewModel.type {
                                case .worthMore, .worthLess:
                                    Text("USD")
                                        .font(Font.mainFont(size: 16))
                                        .foregroundColor(Color.lightActiveLabelNew)
                                default:
                                    Text("%")
                                        .font(Font.mainFont(size: 16))
                                        .foregroundColor(Color.lightActiveLabelNew)
                                }
                            }
                            .modifier(TextFieldModifier(cornerRadius: 24))
                        }
                    }
                }
                .padding(.horizontal, 56)
                
                HStack {
                    PButton(label: "Set alert", width: 134, height: 48, fontSize: 14, enabled: viewModel.canSet) {
                        viewModel.setAlert()
                    }
                    Spacer()
                }
                .padding(.horizontal, 56)
                .padding(.top, 16)
                .padding(.bottom, 27)
                
                HStack(spacing: 0) {
                    Text("You’ll be alerted if...")
                        .padding(.trailing, 60)
                    Text("Alert created")
                        .padding(.leading, 200)
                    Spacer()
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonInactive)
                .padding(.leading, 56)
                
                Spacer().frame(height: 8)
                
                Divider()
                
                ZStack {
                    Rectangle()
                        .fill(Color.exchangerFieldBackground)
                    
                    ScrollView {
                        LazyVStack_(alignment: .leading) {
                            Spacer().frame(height: 8)
                            
                            ForEach(viewModel.alerts) { alert in
                                HStack(spacing: 0) {
                                    HStack {
                                        Text(alert.title ?? "-")
                                        Spacer()
                                    }
                                    Spacer()
                                    Text(Date(timeIntervalSinceReferenceDate: alert.timestamp?.doubleValue ?? 0).timeAgoSinceDate(shortFormat: true))
                                        .foregroundColor(Color.coinViewRouteButtonInactive)

                                    Spacer().frame(width: 100)
                                    Button(action: {
                                        viewModel.deleteAlert(alert)
                                    }) {
                                        Image("trash")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                    }
                                    .foregroundColor(.red)
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .foregroundColor(.coinViewRouteButtonActive)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 50)
                                .frame(maxWidth: .infinity)
                            }
                            .font(.mainFont(size: 12))
                        }
                    }
                }
                .frame(height: 150)
                .padding([.horizontal, .bottom], 4)
            }
        }
        .frame(width: 656, height: 528)
    }
}

struct CreateAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAlertView(coin: Coin.bitcoin())
    }
}

enum AlertType {
    case worthMore(Coin), worthLess(Coin), incrases(Coin), discrases(Coin)
    
    var description: String {
        switch self {
        case .worthMore(let coin):
            return "1.0 \(coin.code) is worth more than..."
        case .worthLess(let coin):
            return "1.0 \(coin.code) is worth less than..."
        case .incrases(let coin):
            return "Value of \(coin.code) incrases by..."
        case .discrases(let coin):
            return "Value of \(coin.code) discrases by..."
        }
    }
}

struct AlertTypePicker: View {
    let coin: Coin
    @Binding var type: AlertType
        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.exchangerFieldBorder, lineWidth: 1)
                )
            
            HStack {
                Text(type.description)
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.coinViewRouteButtonActive)
                Spacer()
                Image("optionArrowDownDark")
            }
            .padding(.horizontal, 18)
            
            MenuButton(
                label: EmptyView(),
                content: {
                    Button("1.0 \(coin.code) is worth more than...") {
                        type = .worthMore(coin)
                    }
                    Button("1.0 \(coin.code) is worth less than...") {
                        type = .worthLess(coin)
                    }
                    Button("Value of \(coin.code) incrases by...") {
                        type = .incrases(coin)
                    }
                    Button("Value of \(coin.code) discrases by...") {
                        type = .discrases(coin)
                    }
                }
            )
            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
        }
    }
}

struct AlertTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        AlertTypePicker(coin: .bitcoin(), type: .constant(.worthMore(.bitcoin())))
            .frame(width: 158, height: 40)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(
                ZStack {
                    Color.portalWalletBackground
                    Color.black.opacity(0.58)
                }
            )
    }
}
