//
//  AdapterManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import RxSwift
import Combine

class AdapterManager {
    private let disposeBag = DisposeBag()

    private let adapterFactory: IAdapterFactory
    private let ethereumKitManager: EthereumKitManager
    private let walletManager: IWalletManager

    private let subject = PublishSubject<Void>()
    private var cancellable = Set<AnyCancellable>()

    private let queue = DispatchQueue(label: "tides.universal.portal.adapter_manager", qos: .userInitiated)
    private var adapters = [Wallet: IAdapter]()

    init(adapterFactory: IAdapterFactory, ethereumKitManager: EthereumKitManager, walletManager: IWalletManager) {
        self.adapterFactory = adapterFactory
        self.ethereumKitManager = ethereumKitManager
        self.walletManager = walletManager
        
        initAdapters(wallets: walletManager.activeWallets)
        
        walletManager.onWalletsUpdatePublisher
            .sink { [weak self] wallets in
                self?.initAdapters(wallets: wallets)
            }
            .store(in: &cancellable)
    }

    private func initAdapters(wallets: [Wallet]) {
        var newAdapters = queue.sync { adapters }

        for wallet in wallets {
            guard newAdapters[wallet] == nil else {
                continue
            }

            if let adapter = adapterFactory.adapter(wallet: wallet) {
                newAdapters[wallet] = adapter
                adapter.start()
            }
        }

        var removedAdapters = [IAdapter]()

        for wallet in Array(newAdapters.keys) {
            guard !wallets.contains(wallet), let adapter = newAdapters.removeValue(forKey: wallet) else {
                continue
            }

            removedAdapters.append(adapter)
        }

        queue.async {
            self.adapters = newAdapters
            self.subject.onNext(())
        }

        removedAdapters.forEach { adapter in
            adapter.stop()
        }
    }

}

extension AdapterManager: IAdapterManager {

    var adaptersReadyObservable: Observable<Void> {
        subject.asObservable()
    }

    func adapter(for wallet: Wallet) -> IAdapter? {
        queue.sync { adapters[wallet] }
    }

    func adapter(for coin: Coin) -> IAdapter? {
        queue.sync {
            guard let wallet = walletManager.activeWallets.first(where: { $0.coin == coin } ) else {
                return nil
            }

            return adapters[wallet]
        }
    }

    func balanceAdapter(for wallet: Wallet) -> IBalanceAdapter? {
        queue.sync { adapters[wallet] as? IBalanceAdapter }
    }

    func transactionsAdapter(for wallet: Wallet) -> ITransactionsAdapter? {
        queue.sync { adapters[wallet] as? ITransactionsAdapter }
    }

    func depositAdapter(for wallet: Wallet) -> IDepositAdapter? {
        queue.sync { adapters[wallet] as? IDepositAdapter }
    }

    func refresh() {
        queue.async {
            for adapter in self.adapters.values {
                adapter.refresh()
            }
        }

        ethereumKitManager.evmKit?.refresh()
    }

    func refreshAdapters(wallets: [Wallet]) {
        queue.async {
            wallets.forEach {
                self.adapters[$0]?.stop()
                self.adapters[$0] = nil
            }
        }

        initAdapters(wallets: walletManager.activeWallets)
    }

    func refresh(wallet: Wallet) {
        let adapter = adapters[wallet]

        switch adapter {
        case is BaseEvmAdapter:
            switch wallet.coin.type {
            case .ethereum, .erc20: ethereumKitManager.evmKit?.refresh()
            default: ()
            }
        default:
            adapter?.refresh()
        }
    }

}