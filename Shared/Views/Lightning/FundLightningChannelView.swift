//
//  FundLightningChannelView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct FundLightningChannelView: View {
    @Binding var viewState: LightningRootView.ViewState
    
    var body: some View {
        Text("FundLightningChannelView")
    }
}

struct FundLightningChannelView_Previews: PreviewProvider {
    static var previews: some View {
        FundLightningChannelView(viewState: .constant(.root))
            .frame(width: 500, height: 650)
            .padding()
    }
}
