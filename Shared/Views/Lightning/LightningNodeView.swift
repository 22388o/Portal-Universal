//
//  LightningNodeView.swift
//  Portal
//
//  Created by farid on 6/11/22.
//

import SwiftUI

struct LightningNodeView: View {
    let node: LightningNode
    
    var body: some View {
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
    }
}

struct LightningNodeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            LightningNodeView(node: LightningNode.sampleNodes[0])
        }
        .frame(width: 460, height: 100)
        .padding()
    }
}
