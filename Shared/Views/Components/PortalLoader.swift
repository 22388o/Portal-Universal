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

struct LoadingAnimationView: View {
    @ObservedObject var viewModel: LoadingViewModel
    
    @State private var animating: Bool = false
    @State private var onHide: Bool = false
    
    @ObservedObject private var counter = Counter(interval: 0.05)
    
    private let frames = (0...59).compactMap { Image("loading-frame_\($0)") }
        
    var body: some View {
        ZStack {
            Color.portalWalletBackground
            
            VStack {
                Spacer()
                
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
                
                if viewModel.isLocked {
                    PTextField(secure: true, text: $viewModel.passcode, placeholder: "Enter passcode", upperCase: false, width: 250, height: 50, onCommit: {
                        viewModel.tryUnlock()
                    })
                    .modifier(ShakeEffect(shakes: viewModel.wrongPasscode ? 1 : 0))
                    .animation(Animation.default.repeatCount(1).speed(5), value: viewModel.wrongPasscode)
                    .padding()
                }
                
                Spacer()
                
                if viewModel.isLocked {
                    HStack {
                        Text("Forgot passcode?")
                            .font(.mainFont(size: 16))
                            .foregroundColor(Color.white.opacity(0.82))
                        
                        Text("Reset")
                            .font(.mainFont(size: 14))
                            .underline()
                            .foregroundColor(Color.red)
                            .contentShape(Rectangle())
                            .onTapGesture {

                            }
                    }
                    .padding(40)
                }
            }
        }
    }
}

struct LoadingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimationView(viewModel: LoadingViewModel.config())
    }
}
