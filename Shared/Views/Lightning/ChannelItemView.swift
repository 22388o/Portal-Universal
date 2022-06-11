//
//  ChannelItemView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct ChannelItemView: View {
    let channel: LightningChannel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .background(Color.black.opacity(0.25))
            
            VStack {
                HStack {
                    Text("Alias:")
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    Text(channel.nodeAlias)
                        .foregroundColor(Color.white)
                    
                }
                
                HStack {
                    Text("Status:")
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(channel.state.description)
                            .foregroundColor(Color.lightActiveLabel)
                        
//                        if channel.state == .waitingFunds {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
//                        }
                    }
                    
                }
                
                HStack {
                    Text("Balance:")
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    Text("\(channel.satValue) sat")
                        .foregroundColor(Color.lightActiveLabel)
                    
                }
                
                if channel.state == .open {
                    Button {
//                        guard let cm = PolarConnectionExperiment.shared.service?.manager.channelManager else { return }
//                        if let channelID = cm.list_channels().first(where: { $0.get_user_channel_id() == channel.id })?.get_channel_id() {
//                            let result = cm.close_channel(channel_id: channelID)
//                            if result.isOk() {
//                                print("Channel cosed")
//                                channel.state = .closed
//                                PolarConnectionExperiment.shared.service?.dataService.update(channel: channel)
//                            } else {
//                                print("Channel closing error:")
//                                let error = result.getError()
//                                switch error?.getValueType() {
//                                case .some(.ChannelUnavailable):
//                                    print("Channel unavaliable")
//                                case .some(.APIMisuseError):
//                                    if let e = error?.getValueAsAPIMisuseError() {
//                                        print("Api misuse error \(e.getErr())")
//                                    }
//                                case .some(.FeeRateTooHigh):
//                                    if let e = error?.getValueAsFeeRateTooHigh() {
//                                        print("Fee rate too high error \(e.getErr())")
//                                    }
//                                case .some(.RouteError):
//                                    if let e = error?.getValueAsRouteError() {
//                                        print("Router error \(e.getErr())")
//                                    }
//                                case .some(.IncompatibleShutdownScript):
//                                    print("IncompatibleShutdownScript")
//                                case .none:
//                                    print("Unknown")
//                                }
//                            }
//                        }
                    } label: {
                        Text("Close")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.white)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .font(.mainFont(size: 14))
            .padding()
        }
        .frame(height: 100)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

struct ChannelItemView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelItemView(
            channel: LightningChannel(id: Int16.random(in: 1...100), satValue: 2000, state: .open, nodeAlias: "Test node")
        )
            .padding()
    }
}

