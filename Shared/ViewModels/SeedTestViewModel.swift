//
//  SeedTestViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine

final class SeedTestViewModel: ObservableObject {
    @Published var testString1 = String()
    @Published var testString2 = String()
    @Published var testString3 = String()
    @Published var testString4 = String()
    
    private(set) var formIsValid = false
    private(set) var testIndices = [Int]()
    
    private var testSolved = [String]()
    
    let seed: [String]

    private var cancalable: AnyCancellable?

    init(seed: [String]) {
        self.seed = seed
        setup()
    }
    
    deinit {
        print("\(#function) deinit")
    }
    
    func setup() {
        while testIndices.count <= 3 {
            let 🎲 = Int.random(in: 1..<seed.count)
            if !testIndices.contains(🎲) {
                testIndices.append(🎲)
            }
        }
                                       
        for index in testIndices {
            testSolved.append(seed[index - 1])
        }
                    
        bindInputs()
        
        print("Test solved: \(testSolved)")
    }
    
    private func bindInputs() {
        cancalable = $testString1.combineLatest($testString2, $testString3, $testString4)
            .sink(receiveValue: { [weak self] output in
                self?.formIsValid = self?.testSolved == [output.0, output.1, output.2, output.3]
            })
    }
}
