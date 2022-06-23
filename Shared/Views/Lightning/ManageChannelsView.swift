//
//  ManageChannelsView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct ManageChannelsView: View {
    @StateObject private var viewModel = ManageChannelsViewModel.config()
    @Binding var viewState: LightningRootView.ViewState
    
    var body: some View {
        VStack {
            ModalNavigationView(title: "Channels", backButtonAction: {
                viewState = .root
            })
            
            HStack {
                Text("Open channels")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.white)
                Spacer()
                
//                    if viewModel.openChannels.isEmpty {
                    Button {
                        withAnimation {
                            viewState = .openChannel
                        }
                    } label: {
                        Image(systemName: "plus.viewfinder")
                            .foregroundColor(Color.accentColor)
                            .font(.system(size: 16, weight: .regular))
                    }
                    .buttonStyle(.borderless)
//                    }
            }
            .padding(.horizontal)
            
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding([.horizontal, .bottom])
            
            if !viewModel.openChannels.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.openChannels) { channel in
                            ChannelItemView(channel: channel)
                        }
                    }
                }
            } else {
                Spacer()
                Text("There is no open channels yet.")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
                Spacer()
            }
        }
    }
}

struct ManageChannelsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            ManageChannelsView(viewState: .constant(.manage))
        }
    }
}

