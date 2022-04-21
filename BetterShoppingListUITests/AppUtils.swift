//
//  AppUtils.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 21/4/22.
//

import Foundation
import XCTest

func launchApp(wait: Bool = true) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = ["testMode"]
    app.launch()
    if wait {
        // wait for the splash screen
        sleep(4)
    }
    return app
}
