//
//  ViewModifiers.swift
//  Portal
//
//  Created by Farid on 25.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import SwiftUI
import Combine

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(Color.lightActiveLabelNew)
                    .font(Font.mainFont(size: 16))
                    .padding(.horizontal, 5)
            }
            content
                .foregroundColor(Color.white)
                .padding(5.0)
        }
    }
}

public struct NavigationBarHider: ViewModifier {
    @State var isHidden: Bool = false

    public func body(content: Content) -> some View {
        content
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(isHidden)
            .onAppear { self.isHidden = true }
    }
}

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.trailing, .leading], 8)
            .padding([.top, .bottom], 4)
            .background(Color.assetViewButton)
            .cornerRadius(12)
            .font(Font.mainFont(size: 12))
            .foregroundColor(.white)
    }
}

struct PButtonEnabledStyle: ViewModifier {
    @Binding var enabled: Bool
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(8)
            .background(enabled ? Color.assetViewButton : Color.pButtonDisableBackground.opacity(0.35))
            .cornerRadius(18)
            .font(Font.mainFont(size: 16))
            .foregroundColor(enabled ? .white : Color.white.opacity(0.35))
//            .overlay(
//                RoundedRectangle(cornerRadius: 18)
//                    .stroke(enabled ? Color.assetViewButton : Color.pButtonDisableBackground, lineWidth: 1)
//            )
    }
}

struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.exchangerFieldBackgroundNew)
            .cornerRadius(26)
//            .overlay(
//                RoundedRectangle(cornerRadius: 26)
//                .stroke(Color.exchangerFieldBackgroundNew, lineWidth: 1)
//            )
    }
}

struct TimeframeButton: ViewModifier {
    var type: AssetMarketValueViewType
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .font(Font.mainFont())
            .foregroundColor(foregroundColor(for: type, isSelected: isSelected))
            .frame(maxWidth: .infinity)
    }
    
    private func foregroundColor(for type: AssetMarketValueViewType, isSelected: Bool) -> Color {
        switch type {
        case .asset:
            return isSelected ? Color.lightActiveLabel : Color.lightInactiveLabel
        case .portfolio:
            return isSelected ? Color.white : Color.darkInactiveLabel
        }
    }
}

struct KeyboardResponsive: ViewModifier {
    @State var currentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.currentHeight)
                .animation(.easeOut(duration: 0.16))
                .onAppear(perform: {
                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
                        .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
                        .compactMap { notification in
                            notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
                    }
                    .map { rect in
                        rect.height - geometry.safeAreaInsets.bottom
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))

                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
                        .compactMap { notification in
                            CGFloat.zero
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                })
        }
    }
}

extension View {
    func keyboardResponsive() -> ModifiedContent<Self, KeyboardResponsive> {
      return modifier(KeyboardResponsive())
    }
}
