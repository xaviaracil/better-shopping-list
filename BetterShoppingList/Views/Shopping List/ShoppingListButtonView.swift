//
//  ShoppingListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/4/22.
//

import SwiftUI

struct ShoppingListButtonView: View {
    @EnvironmentObject private var shoppingAssistant: ShoppingAssistant

    var list: ShoppingList

    var body: some View {
        Button(action: { shoppingAssistant.newList(from: list) }) {
            VStack(alignment: .center) {
                Image(systemName: "cart")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                Text(list.wrappedName)
                    .font(.headline)
            }.padding(EdgeInsets(top: 20.0, leading: 10.0, bottom: 10.0, trailing: 20.0))
        }
        .buttonStyle(.plain)
        .addBorder(.foreground, width: 1.0, cornerRadius: 10.0)
    }
}

struct ShoppingListButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)

        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        let lists = try? context.fetch(persistenceAdapter.savedListsFetchRequest)
        Group {
            ShoppingListButtonView(list: lists!.first!)
                .frame(height: 100)
                .border(.foreground, width: 1.0)
            ShoppingListButtonView(list: lists!.first!)
                .previewInterfaceOrientation(.landscapeLeft)
            ShoppingListButtonView(list: lists!.first!)
                .frame(height: 30)
                .border(.foreground, width: 1.0)
        }
        .environmentObject(shoppingAssistant)
    }
}
