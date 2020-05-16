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


struct WavePosition: AnimatableModifier {
    let waveInd: Int
    let wavesCount: Int
    var time: CGFloat
    public var animatableData: Double {
        get { Double(time) }
        set {
            self.time = CGFloat(newValue)
        }
    }
    func body(content: Content) -> some View {
        let trimmedTime = time - CGFloat(Int(time))
        let oneWaveWidth = CGFloat(1) / CGFloat(wavesCount)
        let initialPosition = oneWaveWidth / 2 + oneWaveWidth * CGFloat(waveInd)
        var currentPosition = initialPosition + trimmedTime
        if currentPosition > 1 + oneWaveWidth / 2{
            currentPosition -= 1
        }
        var startCopyPosition = -oneWaveWidth / 2
        if currentPosition > 1 - oneWaveWidth / 2{
            //this is the last wave and it partly went out of the frame border
            //we will add another copy of this view to the start, so rainbow will start again in a loop
            startCopyPosition = (currentPosition - 1)
        }
        return  GeometryReader{geometry in
            if startCopyPosition > -oneWaveWidth / 2 + 0.00001 {
                content
                    .animation(nil)
                    .position(x: geometry.size.width * startCopyPosition,
                              y: geometry.size.height / 2)
                    .transition(.identity)
                    .zIndex(Double(startCopyPosition))
            }
            content
                .animation(nil)
                .position(x: geometry.size.width * currentPosition,
                          y: geometry.size.height / 2)
                .animation(nil)
                .zIndex(Double(currentPosition))
        }
    }
}
extension View{
    func positionOf(waveNumber waveInd: Int, of wavesCount: Int, inTime: CGFloat) -> some View {
 //       thats wrong - you must store the actual time (getter is used too)
  //      let time = inTime - CGFloat(Int(inTime))
        return self.modifier(WavePosition(waveInd: waveInd, wavesCount: wavesCount, time: inTime))
    }
}

struct RainbowView: View, Animatable{
    let waves: [GradientBorder]
    let fullRainbowAnimationDuration: CGFloat = 1
    @State var rainbowPosition: CGFloat = 0
    var animation: Animation? = Animation.linear(duration: 2).repeatForever(autoreverses: false)
    @State var started = false
    
    var animationStartTime: Date? = nil
    init(rainbowColors: [Color],
        bottomRadius: CGFloat = 50,
        topRadius: CGFloat = 30,
        gradientLength: CGFloat = 20
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
        .drawingGroup()
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
