//
//  ContentView.swift
//  WatchBetterShoppingList WatchKit Extension
//
//  Created by Xavi Aracil on 29/4/22.
//

import SwiftUI

struct ContentView: View {

    @StateObject
    var viewModel = ContentViewModel()

    var body: some View {
        if viewModel.askedForProducts {
            ProgressView()
        } else if viewModel.marketName != "" {
            CurrentListMarketInMarketView(name: viewModel.marketName,
                                          products: viewModel.products)
        } else {
            Text("Not in a market. Please go to a market of your list and try again")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
