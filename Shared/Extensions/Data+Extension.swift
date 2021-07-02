//
//  Data+Extension.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Foundation

extension Data {
    var toStringArray: [String]? {
      return (try? JSONSerialization.jsonObject(with: self, options: [])) as? [String]
    }
}
