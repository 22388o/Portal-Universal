//
//  ReachabilityService.swift
//  Portal
//
//  Created by Farid on 21.10.2021.
//

import Network
import Combine

class ReachabilityService: ObservableObject {
    private let monitorForWifi = NWPathMonitor(requiredInterfaceType: .wifi)
    private let monitorForCellular = NWPathMonitor(requiredInterfaceType: .cellular)
    private let monitorForOtherConnections = NWPathMonitor(requiredInterfaceType: .other)
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var subscriptions = Set<AnyCancellable>()

    private var wifiStatus: NWPath.Status = .requiresConnection {
        didSet {
            isReachableOnWifi = wifiStatus == .satisfied
        }
    }
    private var cellularStatus: NWPath.Status = .requiresConnection {
        didSet {
            isReachableOnCellular =  cellularStatus == .satisfied
        }
    }
    private var otherConnectionsStatus: NWPath.Status = .requiresConnection {
        didSet {
            isReachableOnOtherConnection =  otherConnectionsStatus == .satisfied
        }
    }
    
    @Published private var isReachableOnWifi: Bool = false
    @Published private var isReachableOnCellular: Bool = false
    @Published private var isReachableOnOtherConnection: Bool = false
    
    @Published private(set) var isReachable: Bool = false
    
    func startMonitoring() {
        monitorForWifi.pathUpdateHandler = { [unowned self] path in
            self.wifiStatus = path.status
        }
        monitorForCellular.pathUpdateHandler = { [unowned self] path in
            self.cellularStatus = path.status
        }
        
        monitorForOtherConnections.pathUpdateHandler = { [unowned self] path in
            self.otherConnectionsStatus = path.status
        }
        
        Publishers.Merge3($isReachableOnWifi, $isReachableOnCellular, $isReachableOnOtherConnection)
            .sink { [unowned self] output in
                self.isReachable = output
            }
            .store(in: &subscriptions)
        
        monitorForCellular.start(queue: monitorQueue)
        monitorForWifi.start(queue: monitorQueue)
        monitorForOtherConnections.start(queue: monitorQueue)
    }

    func stopMonitoring() {
        monitorForWifi.cancel()
        monitorForCellular.cancel()
        monitorForOtherConnections.cancel()
    }
}
