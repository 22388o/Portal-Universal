//
//  TopCoinView.swift
//  Portal
//
//  Created by Farid on 03.04.2021.
//

import SwiftUI

struct TopCoinView: View {
    var body: some View {
        VStack(spacing: 0) {
            Group {
                Text("Your portfolio")
                    .font(.mainFont(size: 12))
                    .opacity(0.6)
                Text("$0.00")
                    .font(.mainFont(size: 28))
                    .opacity(0.8)
                
                Spacer().frame(height: 36)
                
                Text("Best performing coins\nin the last 24 hours")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 12))
                    .opacity(0.6)
            }
            .foregroundColor(.white)
                
            Spacer().frame(height: 13)
            
            HStack {
                Button(action: {
                    
                }) {
                    Image("arrowLeftLight")
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                HStack {
                    Image("iconBtc")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("Bitcoin")
                        .font(.mainFont(size: 15))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image("arrowRightLight")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 8)
            
            Spacer().frame(height: 18)
            
            Image("demoGraph")
                .resizable()
                .frame(width: 256, height: 120)
            
            Spacer().frame(height: 18)
            
            Group {
                Text("Price")
                    .font(.mainFont(size: 12))
                    .opacity(0.6)
                Text("$0.00")
                    .font(.mainFont(size: 19))
                    .opacity(0.8)
                Text("+00.0%")
                    .font(.mainFont(size: 19))
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            
            Divider()
                .background(Color.white)
                .opacity(0.12)
                .padding(.vertical, 26)
            
            Group {
                Text("You could be making gains…")
                    .font(.mainFont(size: 14))
                    .opacity(0.8)
                
                Spacer().frame(height: 6)
                
                Text("Create your wallet, add assets and start\ntracking your portfolio and market cap, and\nstart making some gains.")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 12))
                    .opacity(0.6)
            }
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}

struct OnboardingPortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            TopCoinView()
        }
        .frame(width: 312, height: 656)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
