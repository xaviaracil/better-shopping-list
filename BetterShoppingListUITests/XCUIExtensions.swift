//
//  XCUIExtensions.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 5/5/22.
//
import XCTest

extension XCUIElement {
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
}
