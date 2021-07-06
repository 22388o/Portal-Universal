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
        print("Counter is deinited")
    }
}

struct PortalLoader: View {
    private let frames = (0...59).compactMap { Image("loading-frame_\($0)") }
    
    @ObservedObject private var counter = Counter(interval: 0.05)
    @State private var animating: Bool = false
    
    var body: some View {
        frames[counter.value % frames.count]
            .resizable()
            .frame(width: 150, height: 150, alignment: .center)
            .scaleEffect(animating ? 1 : 0.5)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), {
                    animating.toggle()
                })
            }
            .onDisappear {
                counter.reset()
            }
    }
}

struct PortalLoader_Previews: PreviewProvider {
    static var previews: some View {
        PortalLoader()
    }
}
