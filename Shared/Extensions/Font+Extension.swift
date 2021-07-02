//
//  Font+Extension.swift
//  Portal
//
//  Created by Farid on 23.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

extension Font {
    static func mainFont(size: CGFloat = 12, bold: Bool = false) -> Font {
        Font.custom(bold ? "Avenir-Black" : "Avenir-Medium", size: size)
    }
    static func mainFontHeavy(size: CGFloat = 12) -> Font {
        Font.custom("Avenir-Heavy", size: size)
    }
}
