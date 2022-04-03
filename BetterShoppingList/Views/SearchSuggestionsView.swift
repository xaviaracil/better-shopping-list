//
//  SearchSuggestionsView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI

struct SearchSuggestionsView: View {
    @State private var suggestedSearches = ["Iougurt Danone", "Estrella Damm"]
    var body: some View {
        ForEach(suggestedSearches, id: \.self) { suggestion in
            Text(suggestion).searchCompletion(suggestion)
        }
    }
}

struct SearchSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchSuggestionsView()
    }
}
