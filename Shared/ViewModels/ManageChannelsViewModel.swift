//
//  ManageChannelsViewModel.swift
//  Portal
//
//  Created by farid on 6/14/22.
//

import Combine

class ManageChannelsViewModel: ObservableObject {
    @Published var openChannels: [LightningChannel]
    
    init(dataService: ILightningDataService) {
        openChannels = dataService.channels
    }
}

extension ManageChannelsViewModel {
    static func config() -> ManageChannelsViewModel {
        guard let service = Portal.shared.lightningService?.dataService else {
            fatalError("\(#function) lightning data service :/")
        }
        return ManageChannelsViewModel(dataService: service)
    }
}
