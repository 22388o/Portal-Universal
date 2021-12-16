//
//  ICoinStorage.swift
//  Portal
//
//  Created by Farid on 30.07.2021.
//

import Combine

protocol ICoinStorage {
    var onCoinsUpdate: PassthroughSubject<[Coin], Never> { get }
    var coins: [Coin] { get }
}
