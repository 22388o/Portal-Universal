//
//  OpenNewChannelView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct OpenNewChannelView: View {
    @ObservedObject var viewModel: ChannelsViewModel
    @Binding var viewState: LightningViewViewModel.ViewState
    @Environment(\.presentationMode) private var presentationMode
    @State var fundChannel: Bool = false
    @State var selectedNode: LightningNode?
    @State var showAlert: Bool = false
    @State var errorMessage = String()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Text("Open a channel")
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
                                    viewState = .manage
                                }
                            }
                        Spacer()
                    }
                }
                .padding()
                
                if fundChannel {
                    VStack {
                        HStack {
                            Text("On-chain balance:")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightInactiveLabel)
                            
                            Spacer()
                            
                            Text("0.000202 BTC")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightActiveLabel)
                        }
                        .padding(.horizontal)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .background(Color.black.opacity(0.25))
                            
                            VStack {
                                HStack {
                                    Text("Alias:")
                                        .foregroundColor(Color.lightInactiveLabel)

                                    Spacer()
                                    Text(selectedNode!.alias)
                                        .foregroundColor(Color.white)

                                }
                                HStack {
                                    Text("PubKey:")
                                        .foregroundColor(Color.lightInactiveLabel)

                                    Spacer()
                                    
                                    Text(selectedNode!.publicKey)
                                        .foregroundColor(Color.lightActiveLabel)
                                        .multilineTextAlignment(.trailing)

                                }
                                HStack {
                                    Text("Host:")
                                        .foregroundColor(Color.lightInactiveLabel)

                                    Spacer()
                                    Text("\(selectedNode!.host)")
                                        .foregroundColor(Color.lightActiveLabel)

                                }
                                HStack {
                                    Text("Port:")
                                        .foregroundColor(Color.lightInactiveLabel)

                                    Spacer()
                                    Text("\(selectedNode!.port)")
                                        .foregroundColor(Color.lightActiveLabel)

                                }
                            }
                            .font(.mainFont(size: 14))
                            .padding()
                        }
                        .frame(height: 120)
                        .padding(.horizontal)
                        .onDisappear {
                            if let node = selectedNode {
                                var shouldDisconnect: Bool = true
                                for channel in node.channels {
                                    if channel.state != .closed {
                                        shouldDisconnect = false
                                        break
                                    }
                                }
                                if shouldDisconnect && node.connected {
//                                    PolarConnectionExperiment.shared.service?.disconnect(node: node)
                                }
                                selectedNode = nil
                            }
                        }
                        
                        ExchangerView(viewModel: viewModel.exchangerViewModel, isValid: .constant(true), isSendingMax: .constant(false))
                            .padding()
                        
                        Text("Set ammount of BTC you'd like to commit to the channel")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 18) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Transaction fee")
                                    Spacer()
                                    Text(viewModel.txFee)
                                }
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.white)
                                
                                Picker("TxFee", selection: $viewModel.selctionIndex) {
                                    ForEach(0 ..< 3) { index in
                                        Text(TxSpeed.allCases[index].title).tag(index)
                                    }
                                }
                                    .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            VStack {
                                Text(TxSpeed.allCases[viewModel.selctionIndex].description)
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.white)
                                    .opacity(0.6)
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button("Open") {
                            if let node = selectedNode {
                                self.viewModel.openAChannel(node: node)
                                viewModel.channelIsOpened = true
                            }
                        }
                        .modifier(PButtonEnabledStyle(enabled: .constant(true)))
                        .padding()
                    }
                } else {
                    Text("Open channels to other nodes on the network to start using Lightning Network.")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightInactiveLabel)
                        .multilineTextAlignment(.center)
                        .padding()
                    
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
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .background(Color.black.opacity(0.25))
                                    
                                    VStack {
                                        HStack {
                                            Text("Alias:")
                                                .foregroundColor(Color.lightInactiveLabel)

                                            Spacer()
                                            Text(node.alias)
                                                .foregroundColor(Color.white)

                                        }
                                        HStack {
                                            Text("PubKey:")
                                                .foregroundColor(Color.lightInactiveLabel)

                                            Spacer()
                                            
                                            Text(node.publicKey)
                                                .foregroundColor(Color.lightActiveLabel)
                                                .multilineTextAlignment(.trailing)

                                        }
                                        HStack {
                                            Text("Host:")
                                                .foregroundColor(Color.lightInactiveLabel)

                                            Spacer()
                                            Text(node.host)
                                                .foregroundColor(Color.lightActiveLabel)

                                        }
                                        HStack {
                                            Text("Port:")
                                                .foregroundColor(Color.lightInactiveLabel)

                                            Spacer()
                                            Text("\(node.port)")
                                                .foregroundColor(Color.lightActiveLabel)

                                        }
                                    }
                                    .font(.mainFont(size: 14))
                                    .padding()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
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
            }
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
        OpenNewChannelView(viewModel: .init(), viewState: .constant(.manage))
    }
}
