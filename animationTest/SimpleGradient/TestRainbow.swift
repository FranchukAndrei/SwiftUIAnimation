//
//  customState.swift
//  animationTest
//
//  Created by Франчук Андрей on 08.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI


struct TestRainbowView: View{
    var body: some View{
        RainbowView(rainbowColors: [.yellow, .green, .blue])
            .frame(width: 300, height: 100)
    }
}



struct RainbowView: View, Animatable{
    let waves: [GradientBorder]
    @State var rainbowPosition: CGFloat = 0
    var animation: Animation
    @State var started = false
    var animationStartTime: Date? = nil
    init(rainbowColors: [Color],
        bottomRadius: CGFloat = 50,
        topRadius: CGFloat = 30,
        gradientLength: CGFloat = 20,
        startDelay: Double = 0
    ){
        guard var lastColor = rainbowColors.last else {fatalError("no colors to display in rainbow")}
        var allWaves = [GradientBorder]()
        for color in rainbowColors{
            let view = GradientBorder(start: lastColor,
                                      end: color,
                                      bottomRadius: bottomRadius,
                                      topRadius: topRadius,
                                      gradientLength: gradientLength)
            allWaves.append(view)
            lastColor = color
        }
        self.waves = allWaves
        self.animation = Animation.linear(duration: 2).repeatForever(autoreverses: false)
    }
    var body: some View{
        GeometryReader{geometry in
            VStack{
                ZStack{
                    ForEach(self.waves.indices, id: \.self){ind in
                        self.waves[ind]
                            .frame(width: geometry.size.width / CGFloat(self.waves.count) + CGFloat(1)) //seam blinks sometimes bucause of rounding, so fix it by adding "+1"
                            .positionOf(waveNumber: ind, of: self.waves.count, inTime: self.rainbowPosition)
                            .animation(self.started ? self.animation : .default)
                    }
                }
                //to learn how it works comment following:
                    .clipped()
                //and uncomment following:
               // Slider(value: self.$rainbowPosition, in: 0...3)
//                Button(action:{
//                    self.started.toggle()
//                    if self.started {
//                        self.rainbowPosition = 1
//                    }else{
//                        self.rainbowPosition = 0
//                    }
//                }){Text(self.started ? "stop animation" : "start nimation")}
            }
//        .drawingGroup()
        }
        .onAppear(){
            self.started = true
            self.self.rainbowPosition = 1
        }
        
    }
}

struct ContentView_TestRainbow: PreviewProvider {
    static var previews: some View {
        return TestRainbowView()
    }
}
