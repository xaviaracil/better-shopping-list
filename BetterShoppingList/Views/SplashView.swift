//
//  SplashScreen.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/4/22.
//

import SwiftUI

struct SplashView: View {
    @Binding var displayed: Bool

    @State private var scaling = false

    let waitingTime: Double = 1

    var body: some View {
        Image(uiImage: UIImage(named: "Logo") ?? UIImage())
            .resizable()
            .scaledToFit()
            .cornerRadius(20.0)
            .shadow(radius: 5.0)
            .frame(width: 260.0)
            .scaleEffect(scaling ? 1 : 1.05)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatCount(2, autoreverses: false)) {
                    scaling.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + waitingTime) {
                    displayed = true
                }
            }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SplashView(displayed: .constant(false))
            SplashView(displayed: .constant(false))
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
