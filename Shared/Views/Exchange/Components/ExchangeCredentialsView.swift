//
//  ExchangeCredentialsView.swift
//  Portal
//
//  Created by Farid on 16.09.2021.
//

import SwiftUI

struct ExchangeCredentialsView: View {
    let exchange: ExchangeModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            Divider()
                .frame(width: 1)
                .background(Color.gray)
            
            VStack(spacing: 16) {
                VStack(spacing: 21) {
                    CoinImageView(size: 48, url: exchange.icon)
                    
                    Text("Sync \(exchange.name) account")
                        .font(.mainFont(size: 18, bold: false))
                        .foregroundColor(Color.gray)
                }
                
                PTextField(text: .constant(String()), placeholder: "Secret", upperCase: false, width: 284, height: 48)
                PTextField(text: .constant(String()), placeholder: "Key", upperCase: false, width: 284, height: 48)
                
                if exchange.id == "coinbasepro" {
                    PTextField(text: .constant(String()), placeholder: "Passphrase", upperCase: false, width: 284, height: 48)
                }
                
                PButton(bgColor: Color.gray, label: "Sync", width: 284, height: 48, fontSize: 14, enabled: true) {
                    
                }
            }
            .padding(.leading, 24)
        }
    }
}

struct ExchangeCredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExchangeCredentialsView(exchange: ExchangeModel.binanceMock())
            ExchangeCredentialsView(exchange: ExchangeModel.coinbaseMock())
        }
    }
}

