//
//  Arrow.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/4/22.
//

import SwiftUI

struct Arrow: View {
    let lineWidth: CGFloat

    init(lineWidth: CGFloat = 10.0) {
        self.lineWidth = lineWidth
    }

    struct Constants {
        // swiftlint:disable nesting type_name
        struct X {
            static let controlPoint = 60.0
            static let arrowLengthLeft = 40.0
            static let arrowLengthRight = 30.0
            static let vertexOffsetLeft = 3.0
            static let vertexOffsetRight = 1.0

        }
        // swiftlint:disable nesting type_name
        struct Y {
            static let controlPoint = 10.0
            static let arrowLengthLeft = 20.0
            static let arrowLengthRight = 30.0
            static let vertexOffsetLeft = 1.0
            static let vertexOffsetRight = 1.0
        }
    }

    var body: some View {
        GeometryReader { reader in
            let midX = reader.size.width / 2
            let midY = reader.size.height / 2
            let maxY = reader.size.height
            let minY = 0.0

            let bottomPoint = CGPoint(x: midX, y: maxY)
            let topPoint = CGPoint(x: midX, y: minY)
            let midPoint = CGPoint(x: midX, y: midY)

            ZStack {
                Path { path in
                    path.move(to: bottomPoint)
                    // swiftlint:disable line_length
                    path.addCurve(to: topPoint,
                                  control1: midPoint.delta(dx: -Constants.X.controlPoint, dy: -Constants.Y.controlPoint),
                                  control2: midPoint.delta(dx: -Constants.X.controlPoint, dy: Constants.Y.controlPoint))
                }.stroke(lineWidth: self.lineWidth)

                Path { path in
                    path.move(to: topPoint.delta(dx: Constants.X.vertexOffsetLeft, dy: -Constants.Y.vertexOffsetLeft))
                    path.addLine(to: topPoint.delta(dx: -Constants.X.arrowLengthLeft, dy: Constants.Y.arrowLengthLeft))
                    // swiftlint:disable line_length
                    path.move(to: topPoint.delta(dx: -Constants.X.vertexOffsetRight, dy: -Constants.Y.vertexOffsetRight))
                    path.addLine(to: topPoint.delta(dx: Constants.X.arrowLengthRight, dy: Constants.Y.arrowLengthRight))
                }.stroke(lineWidth: self.lineWidth)
            }
        }
    }
}

extension CGPoint {
    // swiftlint:disable identifier_name
    func delta(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}
