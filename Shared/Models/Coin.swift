//
//  Coin.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

struct Coin {
    let code: String
    let name: String
    let color: UIColor
    let icon: UIImage
    
    init(code: String, name: String, color: UIColor = UIColor.clear, icon: UIImage = UIImage()) {
        self.code = code
        self.name = name
        self.color = color
        self.icon = icon
    }
}
