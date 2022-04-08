//
//  ContentViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 5/4/22.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var splashDisplayed = false
    @Published var hideSplash: Bool
    var displaySlash: Bool {
        !splashDisplayed && !hideSplash
    }

    init(hideSplash: Bool = false) {
        self.hideSplash = hideSplash
    }
}
