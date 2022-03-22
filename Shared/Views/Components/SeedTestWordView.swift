//
//  SeedTestWordView.swift
//  Portal
//
//  Created by farid on 3/22/22.
//

import SwiftUI

struct SeedTestWordView: View {
    let word: String
    @Binding var testWords: [String]
    
    var body: some View {
        Text(word)
            .font(.mainFont(size: 14))
            .foregroundColor(.white)
            .frame(width: 90, height: 35)
            .background(testWords.contains(word) ? Color.green : Color.blue)
            .cornerRadius(8)
            .padding(6)
            .onTapGesture {
                withAnimation {
                    if !testWords.contains(word) {
                        testWords.append(word)
                    } else {
                        if let index = testWords.firstIndex(of: word) {
                            testWords.remove(at: index)
                        }
                    }
                }
            }
    }
}

struct SeedTestWordView_Previews: PreviewProvider {
    static var previews: some View {
        SeedTestWordView(word: "test", testWords: .constant(["test", "word"]))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
