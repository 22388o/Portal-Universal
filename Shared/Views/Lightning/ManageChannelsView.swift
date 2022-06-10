//
//  ManageChannelsView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct ManageChannelsView: View {
    @ObservedObject var viewModel: ChannelsViewModel = ChannelsViewModel()
    @State var channelIsOpened: Bool = false
    @State var openNewChannel: Bool = false
    @Binding var viewState: LightningRootView.ViewState
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack {
                    ZStack {
                        Text("Channels")
                            .font(.mainFont(size: 18))
                            .foregroundColor(Color.white)
                        
                        HStack {
                            Text("Back")
                                .foregroundColor(Color.lightActiveLabel)
                                .font(.mainFont(size: 14))
                                .padding()
                                .onTapGesture {
                                    withAnimation {
                                        viewState = .root
                                    }
                                }
                            Spacer()
                        }
                    }
                    .padding()
                    
                    HStack {
                        Text("Open channels")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.white)
                        Spacer()
                        
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
                        
                    }
                    .padding([.horizontal])
//                    .sheet(isPresented: $openNewChannel) {
//
//                    }
                    
                    
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
            .padding()
        }
    }
}

struct ManageChannelsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageChannelsView(viewState: .constant(.manage))
    }
}

