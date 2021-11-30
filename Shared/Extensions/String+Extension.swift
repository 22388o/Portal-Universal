//
//  String+Extension.swift
//  Portal
//
//  Created by Farid on 11/30/21.
//

import Foundation

extension String {
    func timestamp() -> TimeInterval {
        TimeInterval(exactly: self.doubleValue) ?? 0
    }
}
