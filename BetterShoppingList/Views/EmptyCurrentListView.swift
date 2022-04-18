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
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var text: String {
        let initial = "Start searching products"
        if lists.isEmpty {
            return initial
        }
        return initial + " OR Choose a favourite list to start"
    }

    @ViewBuilder
    var body: some View {
        VStack {
            if verticalSizeClass == .compact {
                let arrowHeight = 65.0
                // landscape
                HStack {
                    Arrow(lineWidth: 6.0)
                        .foregroundColor(.accentColor)
                        .padding()
                        .frame(width: 100, height: arrowHeight)
                    Spacer()
                    HStack {
                    Text("Start searching products" + (!lists.isEmpty ? " OR Choose a favourite list to start" : ""))
                        .font(.title2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .alignmentGuide(VerticalAlignment.center, computeValue: { _ in -10 })
                    }
                    Spacer()
                    if !lists.isEmpty {
                        Arrow(lineWidth: 6.0)
                            .foregroundColor(.accentColor)
                            .rotationEffect(.degrees(180))
                            .padding()
                            .frame(width: 100, height: arrowHeight)
                            .alignmentGuide(VerticalAlignment.center, computeValue: { _ in -10 })
                    }
                }
            } else {
                // portrait
                Arrow()
                    .foregroundColor(.accentColor)
                    .padding()
                Group {
                    Text("Start searching products")
                    if !lists.isEmpty {
                        Text("")
                        Text("OR")
                        Text("")
                        Text("Choose a favourite list to start")
                    }
                }
                .font(.title2)
                .multilineTextAlignment(.center)

                if !lists.isEmpty {
                    Arrow()
                        .foregroundColor(.accentColor)
                        .rotationEffect(.degrees(180))
                        .padding()
                }
            }
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(lists, id: \.objectID) { list in
                        ShoppingListButtonView(list: list)
                    }
                }
            }
            .padding(.leading)
            .accessibilityIdentifier("Saved Lists")
        }
    }
}

struct EmptyCurrentListView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let context = container.viewContext
        let persitenceAdapter = CoreDataPersistenceAdapter(viewContext: context,
                                                           coordinator: container.persistentStoreCoordinator)
        let lists = try? context.fetch(persitenceAdapter.savedListsFetchRequest)
        Group {
            EmptyCurrentListView(lists: lists ?? [])
                .previewInterfaceOrientation(.portrait)
                .environment(\.verticalSizeClass, .regular)
            EmptyCurrentListView(lists: lists ?? [])
                .previewInterfaceOrientation(.landscapeRight)
                .environment(\.verticalSizeClass, .compact)
            EmptyCurrentListView(lists: [])
                .previewInterfaceOrientation(.landscapeLeft)
                .environment(\.verticalSizeClass, .compact)
        }
    }
}
