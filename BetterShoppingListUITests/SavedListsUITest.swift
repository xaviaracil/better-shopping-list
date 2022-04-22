//
//  SavedListsUITest.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 21/4/22.
//

import XCTest

class SavedListsUITest: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your
        // tests before they run. The setUp method is a good place to do this.

        // UI tests must launch the application that they test.
        app = launchApp()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShowList() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let sidebarButton = app.buttons["Menu"].firstMatch
        XCTAssertTrue(sidebarButton.exists)
        sidebarButton.tap()

        let list1Button = app.buttons["List 1"].firstMatch
        XCTAssertTrue(list1Button.exists)
        list1Button.tap()

        // There must be the list's name
        let bar = app.descendants(matching: .navigationBar)
        let title  = bar.staticTexts["List 1"]
        XCTAssertTrue(title.waitForExistence(timeout: 1))

        // at least there must be one market
        let predicate = NSPredicate(format: "label BEGINSWITH \"Number of products in market \"")
        let marketText = app.staticTexts.matching(predicate).firstMatch
        XCTAssertTrue(marketText.waitForExistence(timeout: 5))
    }

}
