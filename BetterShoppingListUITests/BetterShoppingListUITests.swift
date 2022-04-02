//
//  BetterShoppingListUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 31/3/22.
//

import XCTest

class BetterShoppingListUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your
        // tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDisplaySearchBar() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // wait for the splash screen
        sleep(4)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let searchField = app.searchFields.element
        XCTAssert(searchField.exists)
        XCTAssertEqual(searchField.placeholderValue, "Search Products Here")
    }

    func testDisplayInitialText() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // wait for the splash screen
        sleep(4)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertTrue(app.staticTexts["Start searching products"].exists)
        XCTAssertFalse(app.staticTexts["OR"].exists)
        XCTAssertTrue(app.scrollViews["Saved Lists"].exists)
        XCTAssertFalse(app.scrollViews["Saved Lists"].images.firstMatch.exists)
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
