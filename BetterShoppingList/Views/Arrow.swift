//
//  Arrow.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/4/22.
//

import SwiftUI

struct Arrow: Shape {
    struct Contants {
        // swiftlint:disable nesting type_name
        struct X {
            static let center = 0.5
            static let left = 0.49
            static let right = 0.51
            static let leftVertex = 0.45
            static let rightVertex = 0.55

        }
        // swiftlint:disable nesting type_name
        struct Y {
            static let top = 1.0
            static let topArrow = 0.95
            static let bottomArrow = 0.15
            static let bottom = 0.1
        }

    }
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height

            path.addLines( [
                CGPoint(x: width * Contants.X.center, y: height * Contants.Y.top),
                CGPoint(x: width * Contants.X.leftVertex, y: height * Contants.Y.topArrow),
                CGPoint(x: width * Contants.X.left, y: height * Contants.Y.topArrow),
                CGPoint(x: width * Contants.X.left, y: height * Contants.Y.bottomArrow),
                CGPoint(x: width * Contants.X.leftVertex, y: height * Contants.Y.bottomArrow),
                CGPoint(x: width * Contants.X.center, y: height * Contants.Y.bottom),
                CGPoint(x: width * Contants.X.rightVertex, y: height * Contants.Y.bottomArrow),
                CGPoint(x: width * Contants.X.right, y: height * Contants.Y.bottomArrow),
                CGPoint(x: width * Contants.X.right, y: height * Contants.Y.topArrow),
                CGPoint(x: width * Contants.X.rightVertex, y: height * Contants.Y.topArrow)
            ])
            path.closeSubpath()
        }
    }
}
