//
//  Dictionary+Extension.swift
//  Portal
//
//  Created by Farid on 26.09.2021.
//

import Foundation

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
    var queryString: String {
        var postDataString = ""
        forEach { tuple in
            if "\(tuple.key)" != "signature" {
                if postDataString.count != 0 {
                    postDataString += "&"
                }
                postDataString += "\(tuple.key)=\(tuple.value)"
            }
        }
        return postDataString
    }
}
