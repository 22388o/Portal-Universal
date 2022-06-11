//
//  FundLightningChannelView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

import Combine
import Coinpaprika

class FundingLightningChannelViewModel: ObservableObject {
    let node: LightningNode
    
    @Published var satAmount = String()
    @Published var fiatValue = String()
    @Published var txFeeSelectionIndex = 1
    
    @Binding var viewState: LightningRootView.ViewState
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewState: Binding<LightningRootView.ViewState>, node: LightningNode, ticker: Ticker?) {
        _viewState = viewState
        self.node = node
        
        let btcPrice = ticker?[.usd].price
        
        $satAmount
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { value in
                "\(((value * (btcPrice?.double ?? 1.0))/1_000_000).rounded(toPlaces: 2))"
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

extension FundingLightningChannelViewModel {
    static func config(viewState: Binding<LightningRootView.ViewState>, node: LightningNode) -> FundingLightningChannelViewModel {
        let ticker = Portal.shared.marketDataProvider.ticker(coin: .bitcoin())
        return FundingLightningChannelViewModel(
            viewState: viewState,
            node: node,
            ticker: ticker
        )
    }
}

struct FundLightningChannelView: View {
    @StateObject private var viewModel: FundingLightningChannelViewModel
    
    init(viewState: Binding<LightningRootView.ViewState>, node: LightningNode) {
        let viewModel = FundingLightningChannelViewModel.config(viewState: viewState, node: node)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ModalNavigationView(title: "Fund a channel", backButtonAction: {
                viewModel.viewState = .openChannel
            })
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
            
            LightningNodeView(node: viewModel.node)
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
                
                Text(TxSpeed.allCases[viewModel.txFeeSelectionIndex].description)
                    .font(Font.mainFont())
                    .foregroundColor(Color.lightActiveLabelNew)
            }
            .padding()
            
            Spacer()
            
            PButtonDark(label: "Fund", height: 40, fontSize: 16, enabled: true, action: {
//                self.viewModel.openAChannel(node: node)
//                viewModel.channelIsOpened = true
            })
            .padding()
        }
    }
}

struct FundLightningChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            FundLightningChannelView(viewState: .constant(.root), node: LightningNode.sampleNodes[0])
        }
        .frame(width: 500, height: 650)
    }
}
