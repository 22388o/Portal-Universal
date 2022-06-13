//
//  LDKChannelPersister.swift
//  Portal
//
//  Created by farid on 6/13/22.
//

import LDKFramework_Mac

class LDKChannelPersister: Persist {
    let dataService: ILightningDataService
    
    func readChannelMonitors() {

    }
    
    init(dataService: ILightningDataService) {
        self.dataService = dataService
        super.init()
    }
    
    override func persist_new_channel(channel_id: OutPoint, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()
        
        dataService.update(channelMonitor: Data(monitorBytes), id: Data(idBytes).hex)
                
        return Result_NoneChannelMonitorUpdateErrZ.ok()
    }
    
    override func update_persisted_channel(channel_id: OutPoint, update: ChannelMonitorUpdate, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()

        dataService.update(channelMonitor: Data(monitorBytes), id: Data(idBytes).hex)
        
        return Result_NoneChannelMonitorUpdateErrZ.ok()
    }
    
}
