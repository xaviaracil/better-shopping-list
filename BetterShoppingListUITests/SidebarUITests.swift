//
//  SidebarUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 21/4/22.
//

import XCTest

class SidebarUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = launchApp()

        let sidebarButton = app.buttons["Menu"].firstMatch
        XCTAssertTrue(sidebarButton.exists)
        sidebarButton.tap()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
    }

    func testOpenSideBar() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        XCTAssertTrue(app.buttons["Current List"].firstMatch.exists)
        XCTAssertTrue(app.buttons["Map"].firstMatch.exists)

        for listIndex in 1...10 {
            XCTAssertTrue(app.staticTexts["List \(listIndex)"].firstMatch.exists)
        }
        XCTAssertTrue(app.staticTexts["Carrefour"].firstMatch.exists)
        XCTAssertTrue(app.staticTexts["Sorli"].firstMatch.exists)
        XCTAssertTrue(app.staticTexts["BonPreu Esclat"].firstMatch.exists)
    }
}
