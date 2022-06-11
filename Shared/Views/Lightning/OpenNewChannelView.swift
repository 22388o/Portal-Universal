//
//  OpenNewChannelView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct OpenNewChannelView: View {
    @StateObject private var viewModel = ChannelsViewModel()
    @Binding var viewState: LightningRootView.ViewState
    @Environment(\.presentationMode) private var presentationMode
    //    @State var selectedNode: LightningNode?
    @State var showAlert: Bool = false
    @State var errorMessage = String()
    private let suggestedNodes = LightningNode.sampleNodes
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                ModalNavigationView(title: "Open a Channel", backButtonAction: {
                    viewState = .manage
                })
                .padding()
                
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
                        ForEach(suggestedNodes) { node in
                            LightningNodeView(node: node)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        viewState = .fundChannel(node)
                                    }
                                    //                                    if PolarConnectionExperiment.shared.service?.connect(node: node) ?? false {
                                    //                                        selectedNode = node
                                    //                                        fundChannel.toggle()
                                    //                                    } else {
                                    //                                        errorMessage = "Unable connect to \(node.alias)"
                                    //                                        showAlert = true
                                    //                                    }
                                }
                                .padding(.horizontal)
                        }
                    }
                }
            }
            //            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Something went wrong:"),
                    message: Text("\(errorMessage)"),
                    dismissButton: Alert.Button.default(
                        Text("Dismiss"), action: {
                            showAlert = false
                        }
                    )
                )
            }
        }
    }
}

struct OpenNewChannelView_Previews: PreviewProvider {
    static var previews: some View {
        OpenNewChannelView(viewState: .constant(.manage))
            .frame(width: 500, height: 650)
            .padding()
    }
}
