//
//  PasscodeSettingsView.swift
//  Portal
//
//  Created by farid on 4/4/22.
//

import SwiftUI

struct PasscodeSettings: View {
    @Binding var showPasscodeSettings: Bool
    
    @ObservedObject var viewModel = PasscodeSetttingsViewModel.config()
            
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Passcode")
                    .font(.mainFont(size: 12, bold: true))
                    .foregroundColor(Color.walletsLabel)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 9)
                    
                Spacer()
                
                PButton(label: "Lock", width: 50, height: 20, fontSize: 10, enabled: viewModel.lockButtonEnabled, action: {
                    viewModel.lock()
                })
                .padding(.trailing)
            }
            
            Divider()
            
            Image("lockedSafeIcon")
                .padding()
            
            Toggle(isOn: $viewModel.protectedWithPasscode) {
                HStack {
                    Text("Protect with passcode")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.lightActiveLabel)
                    Spacer()
                }
            }
            .toggleStyle(SwitchToggleStyle())
            .padding()
            .disabled(!viewModel.protectWithPasscodeToggleEnabled)
            
            if viewModel.protectedWithPasscode {
                if viewModel.hasPasscode {
                    VStack {
                        Text("Lorem ipsum dolor sit amet. Rem voluptatem nobis qui repellendus itaque id rerum voluptate. Hic inventore inventore qui galisum dolorum et consequatur quos ad animi consequatur.")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.walletsLabel)
                        
                        PTextField(secure: true, text: $viewModel.confirmedPasscode, placeholder: "Enter passcode", upperCase: false, width: 245, height: 30)
                        
                        Spacer()
                        PButton(label: "Change passcode", width: 120, height: 30, fontSize: 12, enabled: viewModel.changePasscodeButtonEnabled, action: {
                            withAnimation {
                                viewModel.resetPasscode()
                            }
                        })
                        Spacer()
                    }
                    .padding()
                } else {
                    VStack {
                        Text("Lorem ipsum dolor sit amet. Rem voluptatem nobis qui repellendus itaque id rerum voluptate. Hic inventore inventore qui galisum dolorum et consequatur quos ad animi consequatur.")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.walletsLabel)
                        
                        PTextField(secure: true, text: $viewModel.passcode, placeholder: "Enter pass code", upperCase: false, width: 245, height: 30)
                                            
                        Text("Lorem ipsum dolor sit amet. Rem voluptatem nobis qui repellendus itaque id rerum voluptate. Hic inventore inventore qui galisum dolorum et consequatur quos ad animi consequatur.")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.walletsLabel)
                        
                        PTextField(secure: true, text: $viewModel.confirmedPasscode, placeholder: "Confirm pass code", upperCase: false, width: 245, height: 30)

                        Spacer()
                                            
                        PButton(label: "Set", width: 80, height: 30, fontSize: 12, enabled: viewModel.setPasscodeButtonEnabled, action: {
                            viewModel.setPasscode()
                            withAnimation {
                                showPasscodeSettings.toggle()
                            }
                        })
                        .padding()
                    }
                    .padding(.horizontal)
                }
            } else if viewModel.changePasscode {
                VStack {
                    Text("Lorem ipsum dolor sit amet. Rem voluptatem nobis qui repellendus itaque id rerum voluptate. Hic inventore inventore qui galisum dolorum et consequatur quos ad animi consequatur.")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.walletsLabel)
                    
                    PTextField(secure: true, text: $viewModel.passcode, placeholder: "Enter pass code", upperCase: false, width: 245, height: 30)
                                        
                    Text("Lorem ipsum dolor sit amet. Rem voluptatem nobis qui repellendus itaque id rerum voluptate. Hic inventore inventore qui galisum dolorum et consequatur quos ad animi consequatur.")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.walletsLabel)
                    
                    PTextField(secure: true, text: $viewModel.confirmedPasscode, placeholder: "Confirm pass code", upperCase: false, width: 245, height: 30)

                    Spacer()
                                        
                    PButton(label: "Set", width: 80, height: 30, fontSize: 12, enabled: viewModel.setPasscodeButtonEnabled, action: {
                        withAnimation {
                            showPasscodeSettings.toggle()
                        }
                    })
                    .padding()
                }
                .padding(.horizontal)
            } else {
                Text("Lorem ipsum dolor sit amet. Rem voluptatem nobis qui repellendus itaque id rerum voluptate. Hic inventore inventore qui galisum dolorum et consequatur quos ad animi consequatur.\n\nAut libero maiores sit galisum labore vel doloremque delectus sit distinctio dolor et voluptas fuga. Nam dolorem animi ea consequatur soluta ut reiciendis unde in dolorum aliquam aut sint fugiat et eaque officiis. Est odit dolore ea quia corporis quo dicta velit sed voluptatem rerum eos dolorum corrupti ea voluptatem fuga. Sit expedita earum aut reiciendis galisum qui iure quod.")
                    .multilineTextAlignment(.leading)
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.walletsLabel)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

struct PasscodeSettings_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeSettings(showPasscodeSettings: .constant(false))
            .frame(width: 280)
    }
}
