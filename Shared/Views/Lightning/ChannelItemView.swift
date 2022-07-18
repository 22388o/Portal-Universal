//
//  ChannelItemView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

import Combine
#if os(macOS)
import LDKFramework_Mac
#else
import LDKFramework
#endif

class ChannelItemViewModel: ObservableObject {
    let channel: LightningChannel
    let manager: ChannelManager
    let service: ILightningDataService
    
    var channelID: [UInt8]? {
        manager.list_channels().first(where: { $0.get_user_channel_id() == channel.id })?.get_channel_id()
    }
 
    init(channel: LightningChannel, channelManager: ChannelManager, dataService: ILightningDataService) {
        self.channel = channel
        self.manager = channelManager
        self.service = dataService
    }
    
    func closeChannel() {
        if let channelID = channelID {
            let result = manager.close_channel(channel_id: channelID)
            if result.isOk() {
                print("Channel cosed")
                channel.state = .closed
                service.update(channel: channel)
            } else {
                print("Channel closing error:")
                let error = result.getError()
                switch error?.getValueType() {
                case .some(.ChannelUnavailable):
                    print("Channel unavaliable")
                case .some(.APIMisuseError):
                    if let e = error?.getValueAsAPIMisuseError() {
                        print("Api misuse error \(e.getErr())")
                    }
                case .some(.FeeRateTooHigh):
                    if let e = error?.getValueAsFeeRateTooHigh() {
                        print("Fee rate too high error \(e.getErr())")
                    }
                case .some(.RouteError):
                    if let e = error?.getValueAsRouteError() {
                        print("Router error \(e.getErr())")
                    }
                case .some(.IncompatibleShutdownScript):
                    print("IncompatibleShutdownScript")
                case .none:
                    print("Unknown")
                }
            }
        }
    }
}

extension ChannelItemViewModel {
    static func config(channel: LightningChannel) -> ChannelItemViewModel {
        guard let manager = Portal.shared.lightningService?.manager.channelManager else {
            fatalError("lightning service :/")
        }
        guard let dataService = Portal.shared.lightningService?.dataService else {
            fatalError("lightning data service :/")
        }
        return ChannelItemViewModel(channel: channel, channelManager: manager, dataService: dataService)
    }
}

struct ChannelItemView: View {
    @StateObject private var viewModel: ChannelItemViewModel
    
    init(channel: LightningChannel) {
        _viewModel = StateObject(wrappedValue: ChannelItemViewModel.config(channel: channel))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .background(Color.black.opacity(0.25))
            
            VStack {
                HStack {
                    Text("Alias:")
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    Text(viewModel.channel.nodeAlias)
                        .foregroundColor(Color.white)
                    
                }
                
                HStack {
                    Text("Status:")
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(viewModel.channel.state.description)
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
                    Text("\(viewModel.channel.satValue) sat")
                        .foregroundColor(Color.lightActiveLabel)
                    
                }
                
                if viewModel.channel.state == .open {
                    Button {
                        viewModel.closeChannel()
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

