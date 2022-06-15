//
//  FundLightningChannelView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct FundLightningChannelView: View {
    @StateObject private var viewModel: FundLightningChannelViewModel
    @Binding var viewState: LightningRootView.ViewState
    
    init(viewState: Binding<LightningRootView.ViewState>, node: LightningNode) {
        _viewState = viewState
        _viewModel = StateObject(wrappedValue: FundLightningChannelViewModel.config(node: node))
    }
    
    var body: some View {
        VStack {
            ModalNavigationView(title: "Fund a channel", backButtonAction: {
                viewState = .openChannel
            })
            .padding()
            
            HStack {
                Text("On-chain balance:")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabelNew)
                
                Spacer()
                
                Text(viewModel.onChainBalanceString)
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
            }
            .padding(.horizontal)
            
            LightningNodeView(node: viewModel.node)
                .frame(height: 120)
                .padding(.horizontal)
                .onDisappear {
                    viewModel.disconectIfNeeded()
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
            
            PButtonDark(label: "Fund", height: 40, fontSize: 16, enabled: viewModel.fundButtonAvaliable, action: {
                viewModel.openAChannel()
                withAnimation {
                    viewState = .manage
                }
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
