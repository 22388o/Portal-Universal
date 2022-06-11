//
//  FundLightningChannelView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

import Combine

class FundingLightningChannelViewModel: ObservableObject {
    let coin = Coin.bitcoin()
    let node: LightningNode

    @Published var txFeeSelectionIndex = 1
    @Published var satAmount = String()
    @Published var fiatValue = String()
    @Binding var viewState: LightningRootView.ViewState
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewState: Binding<LightningRootView.ViewState>, node: LightningNode) {
        _viewState = viewState
        self.node = node
        
        let ticker = Portal.shared.marketDataProvider.ticker(coin: coin)
        let price = ticker?[.usd].price
        
        $satAmount
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { value in
                "\(((value * (price?.double ?? 1.0))/1_000_000).rounded(toPlaces: 2))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.fiatValue = "0"
                } else {
                    self?.fiatValue = value
                }
            }
            .store(in: &subscriptions)
    }
}

struct FundLightningChannelView: View {
    @StateObject private var viewModel: FundingLightningChannelViewModel
    
    init(viewState: Binding<LightningRootView.ViewState>, node: LightningNode) {
        let viewModel = FundingLightningChannelViewModel(viewState: viewState, node: node)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Text("Fund a channel")
                    .font(.mainFont(size: 18))
                    .foregroundColor(Color.white)
                    .padding()
                
                HStack {
                    Text("Back")
                        .foregroundColor(Color.lightActiveLabel)
                        .font(.mainFont(size: 14))
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                viewModel.viewState = .openChannel
                            }
                        }
                    Spacer()
                }
            }
            .padding()
            
            HStack {
                Text("On-chain balance:")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabelNew)

                Spacer()
                
                Text("0.000202 BTC")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
            }
            .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .background(Color.black.opacity(0.25))
                
                VStack {
                    HStack {
                        Text("Alias:")
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        Text(viewModel.node.alias)
                            .foregroundColor(Color.white)
                        
                    }
                    HStack {
                        Text("PubKey:")
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text(viewModel.node.publicKey)
                            .foregroundColor(Color.lightActiveLabel)
                            .multilineTextAlignment(.trailing)
                        
                    }
                    HStack {
                        Text("Host:")
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        Text("\(viewModel.node.host)")
                            .foregroundColor(Color.lightActiveLabel)
                        
                    }
                    HStack {
                        Text("Port:")
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        Text("\(viewModel.node.port)")
                            .foregroundColor(Color.lightActiveLabel)
                        
                    }
                }
                .font(.mainFont(size: 14))
                .padding()
            }
            .frame(height: 120)
            .padding(.horizontal)
            .onDisappear {
                var shouldDisconnect: Bool = true
                for channel in viewModel.node.channels {
                    if channel.state != .closed {
                        shouldDisconnect = false
                        break
                    }
                }
                if shouldDisconnect && viewModel.node.connected {
                    //                    PolarConnectionExperiment.shared.service?.disconnect(node: node)
                }
                //                node = nil
            }
            
            HStack(spacing: 8) {
                Image("iconBtc")
                    .resizable()
                    .frame(width: 24, height: 24)
                
                #if os(iOS)
                TextField(String(), text: $viewModel.satAmount)
                    .foregroundColor(Color.white)
                    .modifier(
                        PlaceholderStyle(
                            showPlaceHolder: viewModel.satAmount.isEmpty,
                            placeholder: "0"
                        )
                    )
                    .frame(height: 20)
                    .keyboardType(.numberPad)
                #else
                TextField(String(), text: $viewModel.satAmount)
                    .font(Font.mainFont(size: 16))
                    .foregroundColor(Color.white)
                    .modifier(
                        PlaceholderStyle(
                            showPlaceHolder: viewModel.satAmount.isEmpty,
                            placeholder: "0"
                        )
                    )
                    .frame(height: 20)
                    .textFieldStyle(PlainTextFieldStyle())
                #endif
                
                Text("sat")
                    .foregroundColor(Color.lightActiveLabelNew)
                    .font(Font.mainFont(size: 16))
            }
            .modifier(TextFieldModifierDark(cornerRadius: 26))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(true ? Color.clear : Color.red, lineWidth: 1)
            )
            .padding([.horizontal, .top])
            
            HStack(spacing: 2) {
                Spacer()
                Text(viewModel.fiatValue)
                    .font(Font.mainFont())
                    .foregroundColor(Color.lightActiveLabelNew)
                
                if !viewModel.fiatValue.isEmpty {
                    Text("USD")
                        .font(Font.mainFont())
                        .foregroundColor(Color.lightActiveLabelNew)
                        .padding(.trailing)
                }
            }
            .padding([.horizontal, .bottom])

            
            Text("Set ammount of BTC you'd like to commit to the channel")
                .font(.mainFont(size: 14))
                .foregroundColor(Color.lightActiveLabelNew)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 18) {
                VStack(alignment: .leading) {
                    Picker("TxFee", selection: $viewModel.txFeeSelectionIndex) {
                        ForEach(0 ..< 3) { index in
                            Text(TxSpeed.allCases[index].title).tag(index)
                                .font(Font.mainFont())
                        }
                    }
                    .font(Font.mainFont())
                    .foregroundColor(Color.lightActiveLabelNew)
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack {
                    Text(TxSpeed.allCases[viewModel.txFeeSelectionIndex].description)
                        .font(Font.mainFont())
                        .foregroundColor(Color.lightActiveLabelNew)
                }
            }
            .padding()
            
            Spacer()
            
            Button("Open") {
                //                self.viewModel.openAChannel(node: node)
                //                viewModel.channelIsOpened = true
            }
            .modifier(PButtonEnabledStyle(enabled: .constant(true)))
            .padding()
        }
    }
}

struct FundLightningChannelView_Previews: PreviewProvider {
    static var previews: some View {
        FundLightningChannelView(viewState: .constant(.root), node: LightningNode.sampleNodes[0])
            .frame(width: 500, height: 650)
            .padding()
    }
}
