//
//  ModalNavigationView.swift
//  Portal
//
//  Created by farid on 6/11/22.
//

import SwiftUI

struct ModalNavigationView: View {
    let title: String
    let backButtonAction: (() -> Void)?
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.mainFont(size: 18))
                .foregroundColor(Color.white)
                .padding()
            
            HStack {
                Text("Back")
                    .foregroundColor(Color.lightActiveLabel)
                    .font(.mainFont(size: 14))
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            backButtonAction?()
                        }
                    }
                Spacer()
            }
        }
    }
}

struct ModalNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            ModalNavigationView(title: "Test Navigation", backButtonAction: nil)
        }
    }
}

