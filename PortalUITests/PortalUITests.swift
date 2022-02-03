//
//  PortalUITests.swift
//  PortalUITests
//
//  Created by Manoj Duggirala on 1/11/22.
//

import XCTest
var app: XCUIApplication!

class PortalUITests: XCTestCase {

    override func setUpWithError() throws {

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    func testSetupNewAccountFlow() throws {
                               
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        let portalWindow = XCUIApplication().windows["Portal"]
        portalWindow.buttons["Personal"].click()
        portalWindow.buttons["Create new account"].click()
        portalWindow.click()
        
        let textField = portalWindow.children(matching: .textField).element
        textField.click()
        textField.typeText("test")
        portalWindow.buttons["Continue"].click()
        portalWindow.staticTexts["Copy to clipboard"].click()
        portalWindow.click()
        portalWindow.buttons["Next"].click()
        portalWindow.click()
        
        let textField2 = portalWindow.children(matching: .textField).element(boundBy: 0)
        textField2.click()
        textField2.typeKey("v", modifierFlags:.command)
        portalWindow.click()
        portalWindow.click()
        
        let textField3 = portalWindow.children(matching: .textField).element(boundBy: 1)
        textField3.click()
        textField3.typeKey("v", modifierFlags:.command)
        portalWindow.click()
        
        let textField4 = portalWindow.children(matching: .textField).element(boundBy: 2)
        textField4.click()
        textField4.typeKey("v", modifierFlags:.command)
        portalWindow.click()
        
        let textField5 = portalWindow.children(matching: .textField).element(boundBy: 3)
        textField5.click()
        textField5.typeKey("v", modifierFlags:.command)
        portalWindow.click()
        portalWindow.click()
        textField3.doubleClick()
        textField3.typeKey("v", modifierFlags:.command)
        portalWindow.buttons["Create my wallet"].click()
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
