//
//  GeneralSettingsView.swift
//  Portal
//
//  Created by farid on 4/4/22.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Binding var showPasscodeSettings: Bool
    @State private var infuraKeyString = String()
        
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("General settings")
                    .font(.mainFont(size: 12, bold: true))
                    .foregroundColor(Color.walletsLabel)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 9)
                Spacer()
            }
            
            Divider()
            
            HStack {
                Text("Passcode")
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.lightActiveLabel)
                Spacer()
                
                PButton(label: "Manage", width: 50, height: 20, fontSize: 10, enabled: true) {
                    withAnimation {
                        showPasscodeSettings.toggle()
                    }
                }
            }
            .padding([.top, .horizontal])
            
            VStack(spacing: 6) {
                HStack {
                    Text("Infura API key:")
                        .font(.mainFont(size: 12)).foregroundColor(Color.lightActiveLabel)
                    Spacer()
                }
                
                TextField("Key", text: $infuraKeyString)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView(showPasscodeSettings: .constant(false))
            .frame(width: 300)
    }
}

