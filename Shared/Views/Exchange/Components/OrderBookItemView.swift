//
//  OrderBookItemView.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import SwiftUI

struct OrderBookItemView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
                .offset(y: -1)
            
            HStack(spacing: 0) {
                Text("0.00022421")
                Spacer()
                Text("10")
                Spacer()
                Text("0.00224")
            }
            .font(.mainFont(size: 12))
            .foregroundColor(Color.gray)
            .frame(height: 32)
            .padding(.horizontal, 32)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
        }
    }
}

struct OrderBookItem_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookItemView()
    }
}
