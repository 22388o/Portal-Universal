//
//  EndPointType.swift
//  Portal
//
//  Created by Farid on 12/09/2018.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

