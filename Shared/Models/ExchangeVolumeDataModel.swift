//
//  ExchangeVolumeDataModel.swift
//  Portal
//
//  Created by Farid on 27.09.2021.
//

import Foundation

struct ExchangeVolumeDataModel: Codable {
    let id: String
    let sym: String
    let bVol: Double
    let qVol: Double
}
