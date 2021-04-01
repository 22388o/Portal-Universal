//
//  Int+Extension.swift
//  Portal
//
//  Created by Farid on 31.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

extension Int {
    func enumerationFormattedString() -> String {
        switch self {
        case 1:
            return "1st word"
        case 2:
            return "2nd word"
        case 3:
            return "3rd word"
        case 21:
            return "21st word"
        case 22:
            return "22nd word"
        case 23:
            return "23rd word"
        default:
            return "\(self)th word"
        }
    }
}

