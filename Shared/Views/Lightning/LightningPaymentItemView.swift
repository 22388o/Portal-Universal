//
//  LightningPaymentItemView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct LightningPaymentItemView: View {
    let payment: LightningPayment
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(payment.isExpired ? Color.white.opacity(0.25) : Color.black.opacity(0.25))
            
            VStack {
                HStack {
                    Text(payment.state.description)
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    Text("\(payment.satAmount) sat")
                        .foregroundColor(Color.white)
                    
                }
                
                HStack {
                    Text("\(payment.created.timeAgoSinceDate(shortFormat: false))")
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    Text("fiat amount")
                        .foregroundColor(Color.lightActiveLabel)
                    
                }
                
                HStack {
                    Text("Description")
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    Text(payment.description)
                        .foregroundColor(Color.lightActiveLabel)
                    
                }
            }
            .font(.mainFont(size: 14))
            .padding(.horizontal)
        }
    }
}

struct LightningActivityItemView_Previews: PreviewProvider {
    static var previews: some View {
        LightningPaymentItemView(
            payment: LightningPayment(id: UUID().uuidString, satAmount: 2000, created: Date(), description: "Preview", state: .sent)
        )
            .frame(width: 350, height: 80)
            .padding()
    }
}

