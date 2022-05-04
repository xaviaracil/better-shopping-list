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
        GeometryReader { reader  in
            Group {
                Label(list.name ?? "No Name", systemImage: "cart")
                    .labelStyle(ShoppingListLabelStyle(maxHeight: reader.size.height))
                    .padding(EdgeInsets(top: 20.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
            }
            .frame(width: reader.size.height)
            .accessibilityAddTraits(.isButton)
            .addBorder(.foreground, width: 1, cornerRadius: 10)
            .onTapGesture {
                shoppingAssistant.newList(from: list)
            }
        }
    }
}

struct ShoppingListLabelStyle: LabelStyle {
    let defaultHeight = 220.0
    let defaultSize = 96.0

    var maxHeight: CGFloat?

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .font(.system(size: calcSize()))
                .minimumScaleFactor(0.5)
                .foregroundColor(.accentColor)
            configuration.title
                .font(.headline)
        }
    }

    func calcSize() -> CGFloat {
        return min(defaultHeight, maxHeight ?? defaultHeight) * defaultSize / defaultHeight
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
        }
        .environmentObject(shoppingAssistant)
    }
}
