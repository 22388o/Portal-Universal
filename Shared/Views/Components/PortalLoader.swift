//
//  PortalLoader.swift
//  Portal
//
//  Created by Farid on 06.07.2021.
//

import SwiftUI

private class Counter: ObservableObject {
    private var timer: Timer?

    @Published private(set) var value: Int = 0
    
    init(interval: Double) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in self.value += 1 }
    }
    
    func reset() {
        timer?.invalidate()
    }
    
    deinit {
//        print("Counter is deinited")
    }
}

extension View {
    func isLocked(locked: Binding<Bool>) -> ModifiedContent<Self, LoadingViewModifier> {
        modifier(LoadingViewModifier(locked: locked))
    }
}

struct LoadingViewModifier: ViewModifier {
    @Binding var locked: Bool
            
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if locked {
                LoadingAnimationView()
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

struct LoadingAnimationView: View {
    private let frames = (0...59).compactMap { Image("loading-frame_\($0)") }
    
    @ObservedObject private var counter = Counter(interval: 0.05)
    @State private var animating: Bool = false
    @State private var onHide: Bool = false
    
    var body: some View {
        ZStack {
            Color.portalWalletBackground
            
            frames[counter.value % frames.count]
                .resizable()
                .frame(width: 250, height: 250, alignment: .center)
                .scaleEffect(animating ? 1 : 0.7)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true), {
                        animating.toggle()
                    })
                }
                .onDisappear {
                    onHide = true
                    counter.reset()
                }
        }
    }
}

struct LoadingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimationView()
    }
}
