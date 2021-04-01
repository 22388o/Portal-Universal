//
//  NetworkError.swift
//  Portal
//
//  Created by Farid on 14.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case parsing
    case inconsistentBehavior
    case networkError
}

// MARK: - LocalizedError
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        return "Something went wrong, we will fix it!"
    }
}

