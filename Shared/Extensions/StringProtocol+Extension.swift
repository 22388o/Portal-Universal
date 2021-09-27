//
//  StringProtocol+Extension.swift
//  Portal
//
//  Created by Farid on 27.09.2021.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String {
        prefix(1).uppercased()  + dropFirst()
    }
    var firstCapitalized: String {
        prefix(1).capitalized + dropFirst()
    }
}
