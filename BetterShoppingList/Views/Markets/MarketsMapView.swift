//
//  MarketsMap.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import SwiftUI

struct MarketsMapView<Data>: View
where Data: RandomAccessCollection,
      Data.Element: Market {

    /// markets to display
    var markets: Data


    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MarketsMapView_Previews: PreviewProvider {
    static var previews: some View {
        MarketsMapView()
    }
}
