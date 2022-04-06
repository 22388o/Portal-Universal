//
//  ShakeEffect.swift
//  Portal
//
//  Created by farid on 4/5/22.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: -10 * sin(position * 2 * .pi), y: 0))
    }
    
    init(shakes: Int) {
        position = CGFloat(shakes)
    }
    
    var position: CGFloat
    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }
}
