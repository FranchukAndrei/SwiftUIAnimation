//
//  SwiftUIView.swift
//  animationTest
//
//  Created by Франчук Андрей on 17.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct CustomZIndex: AnimatableModifier {
    let ind: Int
    let totalCount: Int
    let frameWidth: CGFloat
    var time: CGFloat
    public var animatableData: Double {
        get { Double(time) }
        set {
            self.time = CGFloat(newValue)
        }
    }
    func body(content: Content) -> some View {
        let position = Double(SharpWavePosition.calculate(forWave: ind, ofWaves: totalCount, overTime: time))
        print("rect #\(ind + 1) in time \(time) zInd \(position)")
        
        return
            //GeometryReader{geometry in
            //blocking ZIndex and caus strange positioninf
                content
                .zIndex(-position)
                    .offset(x: frameWidth * CGFloat(position) - frameWidth / 2,
                        y: 0)
            //}

    }
}

extension View{
    func customZIndex(itemNumber ind: Int, of totalCount: Int, inFrame: CGSize, inTime: CGFloat) -> some View {
        return self.modifier(CustomZIndex(ind: ind, totalCount: totalCount, frameWidth: inFrame.width, time: inTime))
    }
}
struct ZIndexTestView: View {
    let colors: [Color] = [.green, .blue, .red]
    @State var time: CGFloat = 0
    let animation = Animation.linear(duration: 2)
    var body: some View {
        GeometryReader{geometry in
            VStack{
                ZStack{
                    ForEach(0..<self.colors.endIndex, id: \.self){(ind: Int)in
                        Rectangle()
                            .fill(self.colors[ind])
                            .frame(width: CGFloat(100 + 100), height: CGFloat(100 + 100))
                            .overlay(
                                Text("\(ind + 1)"))
                            .customZIndex(itemNumber: ind, of: self.colors.count, inFrame: geometry.size, inTime: self.time)
    //                    .offset(x: CGFloat(ind * 50) - CGFloat(self.colors.count * 50) / 2,
    //                            y: 0)
                           
                    }
                }
                Slider(value: self.$time, in: 0...1)
                    .animation(self.animation)
                Button(action:{
                    withAnimation(nil){
                        self.time = 0
                    }
                    withAnimation(self.animation){
                        self.time = 1
                    }
                }){
                    Text("play the animation")
                }
            }
        }
    }
}

struct ZIndexTestView_Previews: PreviewProvider {
    static var previews: some View {
        ZIndexTestView()
    }
}
