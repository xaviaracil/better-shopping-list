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
    var lists: Data

    var body: some View {
        VStack {
            Arrow()
                .foregroundColor(.accentColor)
                .padding()
            Text(lists.isEmpty ? "Start searching products" : """
                Start searching products

                OR

                Choose a favourite list to start
                """)
                .font(.title2)
                .multilineTextAlignment(.center)
            if !lists.isEmpty {
                Arrow()
                    .foregroundColor(.accentColor)
                    .rotationEffect(.degrees(180))
                    .padding()
            }
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
        let persitenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        let lists = try? context.fetch(persitenceAdapter.savedListsFetchRequest)
        EmptyCurrentListView(lists: lists ?? [])
    }
}
