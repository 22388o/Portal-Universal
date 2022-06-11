//
//  SelectLightningNodeView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct SelectLightningNodeView: View {
    @Binding var viewState: LightningRootView.ViewState
    @Binding var node: LightningNode?
    private let suggestedNodes = LightningNode.sampleNodes
    
    var body: some View {
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
                ForEach(suggestedNodes) { node in
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
                        self.node = node
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

struct SelectLightningNodeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectLightningNodeView(viewState: .constant(.root), node: .constant(nil))
    }
}
