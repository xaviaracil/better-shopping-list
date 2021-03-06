//
//  MarketMapUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 21/4/22.
//

import XCTest

class MarketMapUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = launchApp()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testMapIsDisplayed() throws {
        let sidebarButton = app.buttons["Menu"].firstMatch
        XCTAssertTrue(sidebarButton.waitForExistence(timeout: 5))
        sidebarButton.tap()

        let mapButton = app.buttons["Map"].firstMatch
        app.scrollDownToElement(element: mapButton)
        XCTAssertTrue(mapButton.exists)
        mapButton.tap()

        let title = app.staticTexts["Markets"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        let allButton = app.buttons["All"].firstMatch
        XCTAssertTrue(allButton.waitForExistence(timeout: 5))

        let map = app.descendants(matching: .map).firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5))
    }

}
