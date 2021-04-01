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
        Color(red: 171.0/255.0, green: 186.0/255.0, blue: 173.0/255.0)
    }
    static var darkInactiveLabel: Color {
        Color.white.opacity(0.6)
    }
    static var assetValueLabel: Color {
        Color(red: 80.0/255.0, green: 80.0/255.0, blue: 92.0/255.0)
    }
    static var gradientTop: Color {
        Color(red: 0.0/255.0, green: 92.0/255.0, blue: 142.0/255.0)
    }
    static var gradientBottom: Color {
        Color(red: 85.0/255.0, green: 148.0/255.0, blue: 174.0/255.0)
    }
    static var assetViewButton: Color {
        Color(red: 41.0/255.0, green: 66.0/255.0, blue: 77.0/255.0)
    }
    static var pButtonDisableBackground: Color {
        Color(red: 204.0/255.0, green: 207.0/255.0, blue: 212.0/255.0)
    }
    static var coinViewRouteButtonActive: Color {
        Color(red: 101.0/255.0, green: 106.0/255.0, blue: 114.0/255.0)
    }
    static var coinViewRouteButtonInactive: Color {
        Color.white
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
    static var blush: Color {
        Color(red: 238.0/255.0, green: 198.0/255.0, blue: 169.0/255.0)
    }
    static var brownishOrange: Color {
        Color(red: 233.0/255.0, green: 134.0/255.0, blue: 49.0/255.0)
    }
    static var portalBackground: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.gradientTop, Color.gradientBottom]), startPoint: .top, endPoint: .bottom)
            Color.black.opacity(0.58)
        }
    }
    
}
