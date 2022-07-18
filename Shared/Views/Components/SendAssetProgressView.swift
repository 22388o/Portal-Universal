//
//  SendAssetProgressView.swift
//  Portal
//
//  Created by farid on 2/5/22.
//

import SwiftUI

struct SendAssetProgressView: View {
    @Binding var step: SendAssetViewModel.SendAssetStep
    
    private var progress: CGFloat {
        switch step {
        case .recipient:
            return 0
        case .amount:
            return 150
        case .summary:
            return 300
        case .sent:
            return 400
        }
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.coinViewRouteButtonInactive)
                    .frame(width: 400, height: 3)
                
                Rectangle()
                    .foregroundColor(Color.pButtonEnabledBackground)
                    .frame(width: progress, height: 3)
                    .animation(.linear(duration: 0.55), value: step)
            }
            
            HStack {
                Text("Recipient")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .background(Color.pButtonEnabledBackground)
                    .cornerRadius(8)
                
                Spacer()
                
                Text("Amount")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(step >= .amount ? Color.white : Color.coinViewRouteButtonActive)
                    .background(step >= .amount ? Color.pButtonEnabledBackground : Color.coinViewRouteButtonInactive)
                    .cornerRadius(8)
                    .animation(.linear(duration: 0.75), value: step)

                Spacer()
                
                Text("Summary")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(step >= .summary ? Color.white : Color.coinViewRouteButtonActive)
                    .background(step >= .summary ? Color.pButtonEnabledBackground : Color.coinViewRouteButtonInactive)
                    .cornerRadius(8)
                    .animation(.linear(duration: 0.75), value: step)

                Spacer()
                
                Text("Sent")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(step >= .sent ? Color.white : Color.coinViewRouteButtonActive)
                    .background(step >= .sent ? Color.pButtonEnabledBackground : Color.coinViewRouteButtonInactive)
                    .cornerRadius(8)
                    .animation(.linear(duration: 0.75), value: step)
            }
            .font(.mainFont(size: 10))
        }
    }
}

struct SendAssetProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SendAssetProgressView(step: .constant(.summary))
            .frame(width: 400)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
