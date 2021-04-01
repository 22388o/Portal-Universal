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
    public func hideNavigationBar() -> some View {
        modifier(NavigationBarHider())
    }
}
