//
//  SplashScreen.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/4/22.
//

import SwiftUI

struct SplashView: View {
    @Binding var displayed: Bool

    @State private var scale: CGFloat = 1

    let waitingTime: Double = 1

    var body: some View {
        GeometryReader { reader in
            VStack {
            Spacer()
            Image(uiImage: UIImage(named: "Logo") ?? UIImage())
                .resizable()
                .scaledToFit()
                .cornerRadius(20.0)
                .shadow(radius: 5.0)
                .frame(width: reader.size.width * 0.6)
                .scaleEffect(scale)
                .animation(.spring(response: 1, dampingFraction: 0.2, blendDuration: 0), value: scale)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + waitingTime) {
                        displayed = true
                    }
                }
            Spacer()
            }
            .frame(width: reader.size.width)
            .onAppear {
                scale = 1.1
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(displayed: .constant(false))
    }
}
