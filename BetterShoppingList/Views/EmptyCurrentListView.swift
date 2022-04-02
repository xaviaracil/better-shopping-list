//
//  EmptyCurrentListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/4/22.
//

import SwiftUI

struct EmptyCurrentListView<Data>: View
where Data: RandomAccessCollection,
      Data.Element: ShoppingList {
    @State var lists: Data

    var body: some View {
        VStack {
            Arrow()
                .foregroundColor(.accentColor)
            Text(lists.isEmpty ? "Start searching products" : """
                Start searching products

                OR

                Choose a favourite list to start
                """)
                .font(.title2)
                .multilineTextAlignment(.center)
            Arrow()
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(180))
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(lists, id: \.objectID) { list in
                        ShoppingListView(list: list)
                    }
                }.padding(.leading)
            }.accessibilityIdentifier("Saved Lists")
        }
    }
}

struct EmptyCurrentListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let lists = try? context.fetch(ShoppingListQueries.savedListsFetchRequest())
        EmptyCurrentListView(lists: lists ?? [])
    }
}
