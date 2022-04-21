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
        Group {
            Label(list.name ?? "No Name", systemImage: "cart")
                .labelStyle(ShoppingListLabelStyle())
                .padding(EdgeInsets(top: 20.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
        }
        .accessibilityAddTraits(.isButton)
        .addBorder(.foreground, width: 1, cornerRadius: 10)
        .onTapGesture {
            shoppingAssistant.newList(from: list)            
        }
    }
}

struct ShoppingListLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .font(.system(size: 96))
                .minimumScaleFactor(0.5)
                .foregroundColor(.accentColor)
            configuration.title
                .font(.headline)
        }
    }
}
struct ShoppingListButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let context = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context,
                                                           coordinator: container.persistentStoreCoordinator)

        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        let lists = try? context.fetch(persistenceAdapter.savedListsFetchRequest)
        Group {
            ShoppingListButtonView(list: lists!.first!)
            ShoppingListButtonView(list: lists!.first!)
                .previewInterfaceOrientation(.landscapeLeft)
        }
        .environmentObject(shoppingAssistant)
    }
}

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}
