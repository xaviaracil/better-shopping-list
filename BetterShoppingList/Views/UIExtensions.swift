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
    var eurosWithoutSign: String {
        self.formatted(.currency(code: "eur").sign(strategy: .never).presentation(.narrow))
    }
}

struct ProductTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .minimumScaleFactor(0.01)
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

    func productTitle() -> some View {
        modifier(ProductTitle())
    }

    func bestPrice() -> some View {
        modifier(OfferBestPrice())
    }
}

struct EmptyDataModifier<Placeholder: View>: ViewModifier {

    let items: [Any]
    let placeholder: Placeholder

    @ViewBuilder
    func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
        }
    }
}

extension List {

    func emptyListPlaceholder(_ items: [Any], _ placeholder: AnyView) -> some View {
        modifier(EmptyDataModifier(items: items, placeholder: placeholder))
    }
}

extension Bool {
     static var watchOS: Bool {
         guard #available(watchOS 8, *) else {
             return true
         }
         return false
     }
 }
