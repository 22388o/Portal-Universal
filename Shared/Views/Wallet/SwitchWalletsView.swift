//
//  SwitchWalletsView.swift
//  Portal
//
//  Created by Farid on 25.04.2021.
//

import SwiftUI

struct SwitchWalletsView: View {
    @Binding var presented: Bool
    
    @ObservedObject private var service: WalletsService
    
    @FetchRequest(
        entity: DBWallet.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \DBWallet.name, ascending: true),
        ]
    ) private var allWallets: FetchedResults<DBWallet>
    
    init(walletService: WalletsService, presented: Binding<Bool>) {
        self.service = walletService
        self._presented = presented
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.94))
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Wallets")
                        .font(.mainFont(size: 12, bold: true))
                        .foregroundColor(Color.walletsLabel)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 9)
                    Spacer()
                }
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(allWallets, id: \.walletID) { wallet in
                            WalletItemView(
                                name: wallet.name,
                                selected: wallet.walletID == service.currentWallet?.walletID
                            )
                            .onTapGesture {
                                withAnimation {
                                    if service.currentWallet?.walletID != wallet.walletID {
                                        service.switchWallet(wallet)
                                    } else {
                                        presented.toggle()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
                
                PButton(label: "Create new wallet", width: 184, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        service.currentWallet = nil
                    }
                }
                                
                PButton(label: "Restore wallet", width: 184, height: 32, fontSize: 12, enabled: true) {
                    
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 216, height: 333)
        .transition(.move(edge: .leading))
    }
}

struct SwitchWalletsView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchWalletsView(walletService: .init(mockedWallet: WalletMock()), presented: .constant(true))
//            .background(Color.yellow)
//            .frame(width: 280, height: 400)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
