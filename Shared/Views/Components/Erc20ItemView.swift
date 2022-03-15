//
//  Erc20ItemView.swift
//  Portal
//
//  Created by farid on 3/10/22.
//

import SwiftUI

struct Erc20ItemView: View {
    @ObservedObject var item: Erc20ItemModel
    
    var body: some View {
        HStack {
            CoinImageView(size: 20, url: item.coin.icon)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(item.coin.name)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightActiveLabel)
                    
                    if item.coin != Coin.bitcoin() && item.coin != Coin.ethereum() {
                        Text("ERC20")
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .font(.mainFont(size: 8))
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                }
                Text(item.coin.code)
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.lightActiveLabelNew)
            }
            Spacer()
            
            Toggle(String(), isOn: $item.isInWallet)
                .toggleStyle(SwitchToggleStyle())
        }
    }
}

struct Erc20ItemView_Previews: PreviewProvider {
    static var previews: some View {
        Erc20ItemView(item: Erc20ItemModel(coin: .bitcoin(), isInWallet: true))
    }
}
