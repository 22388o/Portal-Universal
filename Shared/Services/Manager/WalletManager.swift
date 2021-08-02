//
//  WalletManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import RxSwift
import Combine

class WalletManager {
    var onWalletsUpdatePublisher = PassthroughSubject<[Wallet], Never>()
    
    private let accountManager: IAccountManager
    private let storage: IWalletStorage
    private let disposeBag = DisposeBag()
    private var cancellable = Set<AnyCancellable>()

    private let subject = PublishSubject<[Wallet]>()

    private let queue = DispatchQueue(label: "tides.universal.portal.wallet_manager", qos: .userInitiated)

    private var cachedWallets = [Wallet]()
    private var cachedActiveWallets = [Wallet]()

    init(accountManager: IAccountManager, storage: IWalletStorage) {
        self.accountManager = accountManager
        self.storage = storage
        
        cachedWallets = storage.wallets
        handleUpdate(activeAccount: accountManager.activeAccount)
        
        accountManager.onActiveAccountUpdatePublisher
            .sink { [weak self] account in
                self?.handleUpdate(activeAccount: account)
            }
            .store(in: &cancellable)
        
        storage.onWalletsUpdatePublisher
            .sink { [weak self] _ in
                self?.handleUpdate(activeAccount: accountManager.activeAccount)
            }
            .store(in: &cancellable)
    }

    private func notify() {
        subject.onNext(cachedWallets)
    }

    private func notifyActiveWallets() {
        onWalletsUpdatePublisher.send(cachedActiveWallets)
    }

    private func handleUpdate(activeAccount: Account?) {
        let activeWallets = activeAccount.map { storage.wallets(account: $0) } ?? []

        queue.sync {
            self.cachedActiveWallets = activeWallets
            self.notifyActiveWallets()
        }
    }

}

extension WalletManager: IWalletManager {
    var activeWallets: [Wallet] {
        queue.sync { cachedActiveWallets }
    }

    var wallets: [Wallet] {
        queue.sync { cachedWallets }
    }

    var walletsUpdatedObservable: Observable<[Wallet]> {
        subject.asObservable()
    }

    func preloadWallets() {
        queue.async {
            self.cachedWallets = self.storage.wallets
            self.notify()
        }
    }

    func wallets(account: Account) -> [Wallet] {
        storage.wallets(account: account)
    }

    func handle(newWallets: [Wallet], deletedWallets: [Wallet]) {
        storage.handle(newWallets: newWallets, deletedWallets: deletedWallets)

        queue.async {
            self.cachedWallets.append(contentsOf: newWallets)
            self.cachedWallets.removeAll { deletedWallets.contains($0) }
            self.notify()

            let activeAccount = self.accountManager.activeAccount
            self.cachedActiveWallets.append(contentsOf: newWallets.filter { $0.account == activeAccount })
            self.cachedActiveWallets.removeAll { deletedWallets.contains($0) }
            self.notifyActiveWallets()
        }
    }

    func save(wallets: [Wallet]) {
        handle(newWallets: wallets, deletedWallets: [])
    }

    func delete(wallets: [Wallet]) {
        handle(newWallets: [], deletedWallets: wallets)
    }

    func clearWallets() {
        storage.clearWallets()
    }

}
