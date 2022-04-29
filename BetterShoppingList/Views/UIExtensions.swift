//
//  UIExtensions.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 29/4/22.
//

import SwiftUI

extension Double {
    var euros: String {
        self.formatted(.currency(code: "eur"))
    }
}

struct ProductTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .truncationMode(.tail)
            .font(.headline)
    }
}

struct OfferBestPrice: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(.accentColor)
    }
}

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }

    func marketLabel() -> some View {
        modifier(MarketLabel())
    }

    func productTitle() -> some View {
        modifier(ProductTitle())
    }

    func bestPrice() -> some View {
        modifier(OfferBestPrice())
    }
}

struct MarketLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption2)
    }
}
