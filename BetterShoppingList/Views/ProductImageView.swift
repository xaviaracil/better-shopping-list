//
//  ProductImageView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import SwiftUI

struct ProductImageView: View {
    var product: Product?
    var isSpecialOffer = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                // swiftlint:disable multiple_closures_with_trailing_closure
                AsyncImage(url: product?.imageUrl) { image in
                    image.resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .frame(width: .infinity, height: .infinity, alignment: .center)
                }
                // mark special offers
                if isSpecialOffer {
                    ForEach(0..<4) { index in
                        Rectangle()
                            .fill(.red)
                            .frame(width: geometry.size.width * 0.2,
                                   height: geometry.size.width * 0.2)
                            .rotationEffect(.degrees(Double(index) * 60.0))
                    }
                    .overlay {
                        Text("!")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct ProductImageView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let product = Product(context: context)
        product.name = "Producte 1"
        product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")
        return        Group {
            ProductImageView(product: product, isSpecialOffer: false)
                .border(.foreground, width: 1.0)
                .frame(height: 100.0)
            ProductImageView(product: product, isSpecialOffer: true)
                .border(.foreground, width: 1.0)
                .frame(height: 100.0)
        }
    }
}
