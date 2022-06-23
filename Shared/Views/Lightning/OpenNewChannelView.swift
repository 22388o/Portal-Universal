//
//  OpenNewChannelView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct OpenNewChannelView: View {
    @StateObject private var viewModel = OpenLightningChannelViewModel.config()
    @Binding var viewState: LightningRootView.ViewState    
    
    var body: some View {
        VStack {
            ModalNavigationView(title: "Open a Channel", backButtonAction: {
                viewState = .manage
            })
            
            Text("Open channels to other nodes on the network to start using Lightning Network.")
                .font(.mainFont(size: 14))
                .foregroundColor(Color.lightInactiveLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 40)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.white)
                            .font(.system(size: 16, weight: .regular))
                        Text("Search the network")
                            .foregroundColor(.white)
                            .font(.mainFont(size: 14))
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                Text("    Search for nodes by name, public key, or paste their pubkey@host")
                    .foregroundColor(Color.lightInactiveLabel)
                    .font(.mainFont(size: 10))
            }
            .padding(.horizontal)
            
            HStack {
                Text("Suggested nodes")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 6)
            
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView {
                VStack {
                    ForEach(viewModel.suggestedNodes) { node in
                        LightningNodeView(node: node)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.connect(node: node) {
                                    withAnimation {
                                        viewState = .fundChannel(node)
                                    }
                                } else {
                                    viewModel.errorMessage = "Unable connect to \(node.alias)"
                                    viewModel.showAlert = true
                                }
                            }
                            .padding(.horizontal)
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Something went wrong:"),
                message: Text("\(viewModel.errorMessage)"),
                dismissButton: Alert.Button.default(
                    Text("Dismiss"), action: {
                        viewModel.showAlert = false
                    }
                )
            )
        }

    }
}

struct OpenNewChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            OpenNewChannelView(viewState: .constant(.manage))
        }
        .frame(width: 500, height: 650)
    }
}
