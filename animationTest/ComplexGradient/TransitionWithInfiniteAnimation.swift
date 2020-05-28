//
//  TransitionWithInfiniteAnimation.swift
//  animationTest
//
//  Created by Франчук Андрей on 27.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI
class SomeObservedObject: ObservableObject{
    @Published var text = "text"
}

struct TransitionWithInfiniteAnimation: View {
    @ObservedObject var text = SomeObservedObject()
    @State var isShown = true
    var body: some View {
        VStack{
            Spacer()
            if isShown{
                SpiningRect(text: text)
            }
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: 5)){
                    self.isShown.toggle()
                    self.text.text += "1"
                }
                
            }){
                Text("show")
            }
        }
    }
}

struct SpiningRect: View {
    @ObservedObject var text: SomeObservedObject
    @State var pct: Double = 0
    var body: some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: 300, height: 300)
            .overlay(Text(text.text))
            .rotationEffect(Angle(degrees: 90 * pct))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .transition(.scale)
        .onAppear(){
            self.pct = 1
        }
    }
}


struct TransitionWithInfiniteAnimation_Previews: PreviewProvider {
    static var previews: some View {
        TransitionWithInfiniteAnimation()
    }
}
