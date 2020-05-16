//
//  customState.swift
//  animationTest
//
//  Created by Франчук Андрей on 08.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI


struct ContentView: View{
    @State var position: CGFloat = 0
    var body: some View{
        TestRainbowView()
   //     .border(Color.black, width: 2)
    }
}

struct SimpleView:  Animatable, View{
    public var animatableData: Double {
        get { Double(position) }
        set {
            self.position = CGFloat(newValue)
        }
    }
    var position: CGFloat
    var body: some View{
        ZStack{
            Rectangle()
                .fill(Color.gray)
            BorderView(position: position)
                
        }
    }
}

struct BorderView: View{
    var position: CGFloat
    var body: some View{
        GeometryReader{geometry in

            Rectangle()
                .fill(Color.green)
                .frame(width: 10)
               // .wavePosition(time: self.position)
                .offset(x: self.getXOffset(inSize: geometry.size), y: 0)
                .animation(nil)
        }
    
    }
    
    func getXOffset(inSize: CGSize) -> CGFloat{
        print("position is: \(position)")
        return -inSize.width / 2 + inSize.width * position
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
