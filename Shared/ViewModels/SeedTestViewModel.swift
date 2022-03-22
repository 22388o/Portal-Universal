//
//  SeedTestViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine

final class SeedTestViewModel: ObservableObject {
    private(set) var formIsValid = false
    private(set) var testIndices = [Int]()
    private(set) var testArray = [String]()
    private(set) var testSolved = [String]()
    
    @Published var selectedWords = [String]()
    
    let seed: [String]

    private var cancalable: AnyCancellable?

    init(seed: [String]) {
        self.seed = seed
        setup()
    }
    
    deinit {
//        print("\(#function) deinit")
    }
    
    func setup() {
        while testIndices.count <= 3 {
            let 🎲 = Int.random(in: 1..<seed.count/2)
            if !testIndices.contains(🎲) {
                testIndices.append(🎲)
            }
        }
                                       
        for index in testIndices {
            testSolved.append(seed[index - 1])
            testArray.append(seed[index - 1])
        }
                            
        print("Test solved: \(testSolved)")
        
        while testArray.count < 12 {
            let word = seed.randomElement()!
            if !testArray.contains(word) {
                testArray.append(word)
            }
        }
        
        testArray.shuffle()
        
        bindInputs()
    }
    
    private func bindInputs() {
        cancalable = $selectedWords.sink { [weak self] _selectedWords in
            self?.formIsValid = self?.testSolved == _selectedWords
        }
    }
}
