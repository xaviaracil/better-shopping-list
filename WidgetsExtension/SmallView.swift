//
//  SmallView.swift
//  WidgetsExtensionExtension
//
//  Created by Xavi Aracil on 4/5/22.
//

import SwiftUI
import WidgetKit

struct SmallView: View {
    var entry: ShoppingListEntry

    var body: some View {
        ZStack {
            Color("WidgetBackground")
            VStack {
                Spacer()
                Label("\(entry.products.count)", systemImage: "bag.fill")
                Label("\(entry.products.groupedByMarket(markets: []).count)", systemImage: "bag.circle")
                Spacer()
                EarnedView(value: entry.earned)
            }
            .font(.largeTitle)
            .foregroundColor(.white)
        }
    }
}

struct SmallView_Previews: PreviewProvider {
    static var previews: some View {
        SmallView(entry: ShoppingListEntry(date: Date(),
                                           products: [],
                                           earned: 10.20))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
