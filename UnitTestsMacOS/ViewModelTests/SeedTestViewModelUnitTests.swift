//
//  SeedTestViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal

class SeedTestViewModelUnitTests: XCTestCase {
    
    private var sut: SeedTestViewModel!
    private let mnemonicWords = [
        "kit", "clog", "mesh", "scrap", "blood", "frost", "siege", "blind", "combine", "model", "village", "comics",
        "rival", "august", "develop", "betray", "boy", "surprise", "unusual", "strike", "sound", "morning", "escape", "alter"
    ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = SeedTestViewModel(seed: mnemonicWords)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testDefaultValues() throws {
        XCTAssertEqual(sut.formIsValid, false)
        XCTAssertEqual(sut.testIndices.count, 4)
        XCTAssertEqual(sut.testSolved.count, 4)
        XCTAssertEqual(sut.testArray.count, 12)
        XCTAssertEqual(sut.selectedWords.isEmpty , true)
    }

    func testFormIsValid() throws {
        let solvedTest = sut.testSolved
        
        XCTAssertEqual(sut.formIsValid, false)
        
        sut.selectedWords.append(solvedTest[0])
        
        XCTAssertEqual(sut.formIsValid, false)
        
        sut.selectedWords.append(solvedTest[1])

        XCTAssertEqual(sut.formIsValid, false)
        
        sut.selectedWords.append(solvedTest[2])

        XCTAssertEqual(sut.formIsValid, false)
        
        sut.selectedWords.append(solvedTest[3])

        XCTAssertEqual(sut.formIsValid, true)
    }
}
