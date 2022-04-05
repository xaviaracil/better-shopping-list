//
//  ShoppingListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/4/22.
//

import SwiftUI

struct ShoppingListView: View {
    var list: ShoppingList

    var body: some View {

        Group {
            Label(list.name ?? "No Name", systemImage: "cart")
                .labelStyle(ShoppingListLabelStyle())
                .padding(EdgeInsets(top: 30.0, leading: 20.0, bottom: 10.0, trailing: 20.0))
        }
        .addBorder(.foreground, width: 1, cornerRadius: 10)
    }
}

struct ShoppingListLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .font(.system(size: 96))
                .foregroundColor(.accentColor)
            configuration.title
                .font(.headline)
        }
    }
}
struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let persitenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        let lists = try? context.fetch(persitenceAdapter.savedListsFetchRequest)
        ShoppingListView(list: lists!.first!)
    }
}

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}
