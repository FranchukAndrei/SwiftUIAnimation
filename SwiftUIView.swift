//
//  SwiftUIView.swift
//  animationTest
//
//  Created by Франчук Андрей on 03.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var animationAmount: CGFloat = 1

    var body: some View {
        Button("Tap Me") {
             self.animationAmount += 1
        }
        .padding(40)
        .background(Color.red)
        .foregroundColor(.white)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.red)
                .scaleEffect(animationAmount)
               // .opacity(Double(3 - animationAmount))
                .animation(
                    Animation.easeOut(duration: 1)
                      //  .repeatForever(autoreverses: false)
                )
        )
        .onAppear {
            self.animationAmount = 2
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
