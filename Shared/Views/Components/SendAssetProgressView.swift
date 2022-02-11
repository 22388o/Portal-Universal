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
            return 200
        case .summary:
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
                    .animation(.linear(duration: 0.55))
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
                    .foregroundColor(step == .amount || step == .summary ? Color.white : Color.coinViewRouteButtonActive)
                    .background(step == .amount || step == .summary ? Color.pButtonEnabledBackground : Color.coinViewRouteButtonInactive)
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.75))
                
                Spacer()
                
                Text("Summary")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(step == .summary ? Color.white : Color.coinViewRouteButtonActive)
                    .background(step == .summary ? Color.pButtonEnabledBackground : Color.coinViewRouteButtonInactive)
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.75))
                
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
