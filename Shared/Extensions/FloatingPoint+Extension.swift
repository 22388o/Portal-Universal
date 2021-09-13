//
//  FloatingPoint+Extension.swift
//  Portal
//
//  Created by Farid on 13.09.2021.
//

import Foundation

extension FloatingPoint {
    var isInteger: Bool {
        return truncatingRemainder(dividingBy: 1) == 0
    }
}
