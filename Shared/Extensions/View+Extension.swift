//
//  View+Extension.swift
//  Portal
//
//  Created by Farid on 03.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
//    public func hideNavigationBar() -> some View {
//        modifier(NavigationBarHider())
//    }
    
    func iPadLandscapePreviews() -> some View {
        Group {
            self
                .previewLayout(.fixed(width: 1080, height: 810))
                .previewDisplayName("10.2 iPad")
            
            self
                .previewLayout(.fixed(width: 1112, height: 834))
                .previewDisplayName("10.5 iPad Air")
            
            self
                .previewLayout(.fixed(width: 1180, height: 820))
                .previewDisplayName("10.9 iPad Air")
            
            self
                .previewLayout(.fixed(width: 1194, height: 834))
                .previewDisplayName("11 iPad Pro, 10.5 iPad Pro")
            
            
            self
                .previewLayout(.fixed(width: 1366, height: 1024))
                .previewDisplayName("12.9 iPad Pro")
        }
    }
}
