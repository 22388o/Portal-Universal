//
//  Color+Extension.swift
//  Portal
//
//  Created by Farid on 13.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    static var lightActiveLabel: Color {
        Color(red: 101.0/255.0, green: 106.0/255.0, blue: 114.0/255.0)
    }
    static var lightActiveLabelNew: Color {
        Color(red: 147.0/255.0, green: 162.0/255.0, blue: 170.0/255.0)
    }
    static var lightInactiveLabel: Color {
        Color(red: 171.0/255.0, green: 176.0/255.0, blue: 173.0/255.0)
    }
    static var darkInactiveLabel: Color {
        Color.white.opacity(0.6)
    }
    static var assetValueLabel: Color {
        Color(red: 80.0/255.0, green: 80.0/255.0, blue: 92.0/255.0)
    }
    static var walletGradientTop: Color {
        Color(red: 0.0/255.0, green: 92.0/255.0, blue: 142.0/255.0)
    }
    static var wallerGradientBottom: Color {
        Color(red: 85.0/255.0, green: 148.0/255.0, blue: 174.0/255.0)
    }
    static var swapGradientTop: Color {
        Color(red: 96.0/255.0, green: 12.0/255.0, blue: 153.0/255.0)
    }
    static var swapGradientBottom: Color {
        Color(red: 172.0/255.0, green: 26.0/255.0, blue: 89.0/255.0)
    }
    static var assetViewButton: Color {
        Color(red: 41.0/255.0, green: 66.0/255.0, blue: 77.0/255.0)
    }
    static var pButtonEnabledBackground: Color {
        Color(red: 8.0/255.0, green: 137.0/255.0, blue: 206.0/255.0)
    }
    static var pButtonDisableBackground: Color {
        Color(red: 204.0/255.0, green: 207.0/255.0, blue: 212.0/255.0)
    }
    static var coinViewRouteButtonActive: Color {
        Color(red: 101.0/255.0, green: 106.0/255.0, blue: 114.0/255.0)
    }
    static var coinViewRouteButtonInactive: Color {
        Color(red: 171.0/255.0, green: 176.0/255.0, blue: 183.0/255.0)
    }
    static var txListTxType: Color {
        Color(red: 7.0/255.0, green: 123.0/255.0, blue: 184.0/255.0)
    }
    static var exchangerFieldBackground: Color {
        Color(red: 249.0/255.0, green: 249.0/255.0, blue: 251.0/255.0)
    }
    static var exchangerFieldBackgroundNew: Color {
        Color(red: 40.0/255.0, green: 70.0/255.0, blue: 86.0/255.0)
    }
    static var exchangerFieldBorder: Color {
        Color(red: 235.0/255.0, green: 236.0/255.0, blue: 242.0/255.0)
    }
    static var createWalletLabel: Color {
        Color(red: 73.0/255.0, green: 77.0/255.0, blue: 83.0/255.0)
    }
    static var mnemonicBackground: Color {
        Color(red: 255.0/255.0, green: 248.0/255.0, blue: 233.0/255.0)
    }
    static var mango: Color {
        Color(red: 253.0/255.0, green: 179.0/255.0, blue: 64.0/255.0)
    }
    static var seedBoxBorder: Color {
        Color(red: 255.0/255.0, green: 156.0/255.0, blue: 49.0/255.0)
    }
    static var seedBoxBackground: Color {
        Color(red: 254.0/255.0, green: 248.0/255.0, blue: 233.0/255.0)
    }
    static var walletExchangeSwitchActentLabel: Color {
        Color(red: 68.0/255.0, green: 73.0/255.0, blue: 82.0/255.0)
    }
    static var walletsLabel: Color {
        Color(red: 85.0/255.0, green: 91.0/255.0, blue: 100.0/255.0)
    }
    static var selectedWallet: Color {
        Color(red: 101.0/255.0, green: 153.0/255.0, blue: 231.0/255.0)
    }
    static var brownishOrange: Color {
        Color(red: 228.0/255.0, green: 114.0/255.0, blue: 27.0/255.0)
    }
    static var blush: Color {
        Color(red: 234.0/255.0, green: 186.0/255.0, blue: 149.0/255.0)
    }
    static var doneButtonBg: Color {
        Color(red: 50.0/255.0, green: 65.0/255.0, blue: 72.0/255.0)
    }
    static var exchangeBuyButtonColor: Color {
        Color(red: 5.0/255.0, green: 191.0/255.0, blue: 103.0/255.0).opacity(0.94)
    }
    static var exchangeSellButtonColor: Color {
        Color(red: 226.0/255.0, green: 70.0/255.0, blue: 105.0/255.0).opacity(0.94)
    }
    static var exchangeBorderColor: Color {
        Color(red: 225.0/255.0, green: 223.0/255.0, blue: 239.0/255.0)
    }
    static var exchangeBorderColorDark: Color {
        Color(red: 67.0/255.0, green: 63.0/255.0, blue: 35.0/255.0)
    }
    static var portalWalletBackground: some View {
        LinearGradient(gradient: Gradient(colors: [Color.walletGradientTop, Color.wallerGradientBottom]), startPoint: .top, endPoint: .bottom)
    }
    static var portalSwapBackground: some View {
        LinearGradient(gradient: Gradient(colors: [Color.swapGradientTop, Color.swapGradientBottom]), startPoint: .top, endPoint: .bottom)
    }
    static var pButtonShadowColor: Color {
        Color(red: 24.0/255.0, green: 22.0/255.0, blue: 40.0/255.0)
    }
}
