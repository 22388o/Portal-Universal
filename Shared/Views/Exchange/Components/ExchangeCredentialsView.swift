//
//  ExchangeCredentialsView.swift
//  Portal
//
//  Created by Farid on 16.09.2021.
//

import SwiftUI

struct ExchangeCredentialsView: View {
    @ObservedObject var viewModel: ExchangeSetupViewModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            Divider()
                .frame(width: 1)
                .background(Color.gray)
            
            VStack(spacing: 16) {
                VStack(spacing: 21) {
                    CoinImageView(size: 48, url: viewModel.exchangeToSync?.icon ?? String())
                    
                    Text("Sync \(viewModel.exchangeToSync?.name ?? "Undefined") account")
                        .font(.mainFont(size: 18, bold: false))
                        .foregroundColor(Color.gray)
                }
                
                PTextField(text: $viewModel.secret, placeholder: "Secret", upperCase: false, width: 284, height: 48)
                PTextField(text: $viewModel.key, placeholder: "Key", upperCase: false, width: 284, height: 48)
                
                if viewModel.exchangeToSync?.id == "coinbasepro" {
                    PTextField(text: $viewModel.passphrase, placeholder: "Passphrase", upperCase: false, width: 284, height: 48)
                }
                
                PButton(bgColor: Color.gray, label: "Sync", width: 284, height: 48, fontSize: 14, enabled: viewModel.syncButtonEnabled) {
                    viewModel.syncExchange()
                }
            }
            .padding(.leading, 24)
        }
    }
}

struct ExchangeCredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeCredentialsView(viewModel: ExchangeSetupViewModel.config())
    }
}

