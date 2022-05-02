//
//  FavoriteButton.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 22/4/22.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding
    var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Label("Favorite", systemImage: "star")
                .symbolVariant(isOn ? .fill : .none)
        }
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(isOn: .constant(true))
        FavoriteButton(isOn: .constant(false))
    }
}
