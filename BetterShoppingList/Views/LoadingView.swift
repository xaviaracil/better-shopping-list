//
//  LoadingView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 9/5/22.
//

import SwiftUI

struct LoadingView: View {
    let test: Bool

    @StateObject
    var viewModel: LoadingViewModel

    @State private var scaling = false

    @State private var loaded = false

    init(test: Bool, modelProvider: ModelProvider) {
        self.test = test
        _viewModel = .init(wrappedValue: LoadingViewModel(test: test, modelProvider: modelProvider))
    }

    @ViewBuilder
    var body: some View {
        if !viewModel.loaded {
            VStack(alignment: .center) {
                Image(uiImage: UIImage(named: "Logo") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20.0)
                    .shadow(radius: 5.0)
                    .frame(width: 260.0)
                    .scaleEffect(scaling ? 1 : 1.05)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                            scaling.toggle()
                        }
                    }
                CompactStack {
                    Text("Downloading data (\(viewModel.index + 1)/\(viewModel.count))…")
                    ProgressView(viewModel.progress)
                        .frame(width: 260.0)
                        .padding(.top)
                }
                .padding(.top)
            }.task {
                viewModel.load()
                }
        } else {
            ContentView()
                .environment(\.managedObjectContext, viewModel.modelProvider.viewContext)
                .environmentObject(viewModel.modelProvider.shoppingAssistant!)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView(test: true, modelProvider: ModelProvider())
            LoadingView(test: true, modelProvider: ModelProvider())
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
