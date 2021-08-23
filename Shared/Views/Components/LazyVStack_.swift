//
//  LazyVStack_.swift
//  Portal
//
//  Created by Farid on 23.08.2021.
//

import SwiftUI

struct LazyVStack_<Content> : View where Content : View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    var body: some View {
        #if os(iOS)
        LazyVStack(alignment: alignment, spacing: spacing, content: content)
        #else
        if #available(OSX 11.0, *) {
            LazyVStack(alignment: alignment, spacing: spacing, content: content)
        } else {
            VStack(alignment: alignment, spacing: spacing, content: content)
        }
        #endif
    }

    init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
}

