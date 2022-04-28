//
//  CurrentListMarketInMarketView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 28/4/22.
//

import SwiftUI

struct CurrentListMarketInMarketView: View {
    var name: String
    @ObservedObject
    var viewModel: CurrentListMarketInMarketViewModel

    init(name: String, products: [ChosenProduct]) {
        self.name = name
        _viewModel = .init(wrappedValue: CurrentListMarketInMarketViewModel(products: products))
    }

    var sortedProducts: [ChosenProduct] {
        viewModel.products.sorted { !$0.inBasket && $1.inBasket }
    }

    var body: some View {
        List {
            ForEach(sortedProducts, id: \.self) { product in
                HStack {
                    ProductImageView(product: product.offer?.product, isSpecialOffer: product.isSpecialOffer)
                        .frame(width: 90, height: 90)

                    VStack(alignment: .leading) {
                        Text(product.offer?.product?.name ?? "No Name")
                            .strikethrough(product.inBasket, color: .accentColor)
                            .productTitle()
                        Text(product.price.formatted(.currency(code: "eur")))
                            .strikethrough(product.inBasket, color: .accentColor)
                            .bestPrice()
                        Text("Quantity: \(product.quantity)")
                            .strikethrough(product.inBasket, color: .accentColor)
                            .font(.subheadline)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.toggleInBasket(product)
                    }) {
                        Label(product.inBasket ? "Remove from cart" : "Add to cart",
                              systemImage: product.inBasket ? "checkmark.circle" : "circle")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                            .labelStyle(.iconOnly)
                    }
                }.opacity(product.inBasket ? 0.7 : 1.0)
            }
        }
        .listStyle(.plain)
    }
}

struct CurrentListMarketInMarketView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentListMarketInMarketView(name: "Market 1", products: [])
    }
}
