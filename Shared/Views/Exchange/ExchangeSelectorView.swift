//
//  ExchangeSelectorView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct ExchangeSelectorView: View {
    @Binding var state: ExchangeViewMode
    @Binding var selectorState: ExchangeSelectorState
    let exchanges: [ExchangeModel]
    let panelWidth: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Exchange")
                    .font(.mainFont(size: 15, bold: false))
                    .foregroundColor(.white)
                Spacer()
                if state != .full {
                    Image("hidePanelIcon")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                state = .compactLeft
                            }
                        }
                }
            }
            .padding(.top, 25)
            .padding(.bottom, 12)
            
            ExchangePicker(state: $selectorState, exchanges: exchanges)
                .padding(.bottom, 12)
            
            Rectangle()
                .foregroundColor(Color.white.opacity(0.10))
                .frame(height: 1)
        }
        .padding(.horizontal, panelWidth == 320 ? 32 : 20)
        .frame(height: 101)
    }
}

struct ExchangeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExchangeSelectorView(state: .constant(.full), selectorState: .constant(.merged), exchanges: [ExchangeModel.binanceMock(), ExchangeModel.coinbaseMock()], panelWidth: 320)
            ExchangeSelectorView(state: .constant(.compactRight), selectorState: .constant(.selected(exchange: ExchangeModel.binanceMock())), exchanges: [ExchangeModel.binanceMock(), ExchangeModel.coinbaseMock()], panelWidth: 320)
            ExchangeSelectorView(state: .constant(.compactLeft), selectorState: .constant(.selected(exchange: ExchangeModel.binanceMock())), exchanges: [ExchangeModel.binanceMock()], panelWidth: 320)
        }
    }
}
