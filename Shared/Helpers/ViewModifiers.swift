//
//  ViewModifiers.swift
//  Portal
//
//  Created by Farid on 25.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import SwiftUI
import Combine

public struct AccessibilityIdentifiebleModifier: ViewModifier {
    let identifier: String
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(macOS 11.0, *) {
            content
                .accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}

struct LoadingViewModifier: ViewModifier {
    @StateObject private var viewModel = LoadingViewModel.config()
    @Binding var locked: Bool
            
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if locked {
                LoadingAnimationView(viewModel: viewModel)
                    .zIndex(1)
                    .transition(
                        AnyTransition.asymmetric(
                            insertion: AnyTransition.identity,
                            removal: AnyTransition.scale(scale: 15)
                                .combined(with: AnyTransition.opacity)
                        )
                        .animation(.easeInOut(duration: 0.5))
                    )
            }
        }
    }
}

struct ModalViewFrameViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modalViewStrokeColor, lineWidth: 8)
                        .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 0)
                )
            
            content
        }
    }
    
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var padding: CGFloat = 5

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(Color.lightInactiveLabel)
                    .font(Font.mainFont(size: 16))
                    .padding(.horizontal, padding)
            }
            content
                .foregroundColor(Color.white)
                .padding(padding)
        }
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
            .font(Font.mainFont(size: 12))
            .foregroundColor(enabled ? .white : Color.white.opacity(0.35))
            .buttonStyle(.plain)
//            .overlay(
//                RoundedRectangle(cornerRadius: 18)
//                    .stroke(enabled ? Color.assetViewButton : Color.pButtonDisableBackground, lineWidth: 1)
//            )
    }
}

struct TextFieldModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color.exchangerFieldBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.exchangerFieldBorder, lineWidth: 1)
            )
    }
}

struct TextFieldModifierDark: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color.exchangerFieldBackgroundDark)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.exchangerFieldBackgroundDark, lineWidth: 1)
            )
    }
}

struct SmallTextFieldModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height: 32)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(red: 222/255, green: 223/255, blue: 229/255), lineWidth: 1)
            )
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
//                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
//                        .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
//                        .compactMap { notification in
//                            notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
//                    }
//                    .map { rect in
//                        rect.height - geometry.safeAreaInsets.bottom
//                    }
//                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
//
//                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
//                        .compactMap { notification in
//                            CGFloat.zero
//                    }
//                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                })
        }
    }
}

extension View {
    func keyboardResponsive() -> ModifiedContent<Self, KeyboardResponsive> {
      return modifier(KeyboardResponsive())
    }
}
