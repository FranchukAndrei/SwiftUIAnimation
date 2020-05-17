//
//  AdvancedTimingRainbow.swift
//  animationTest
//
//  Created by Франчук Андрей on 16.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct AdvancedTimingRainbow: View {
    var rightSideWaveView: SharpRainbowView
    let height: CGFloat = 40
    let middleSpacer: CGFloat = 0.4//whole width = 1
    init(){
        rightSideWaveView = SharpRainbowView(rainbowColors: [.yellow, .green, .blue])
    }
    var body: some View {
        GeometryReader{geometry in
            HStack{
                self.rightSideWaveView
                    .frame(height: self.height)
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
                Spacer()
                    .frame(width: geometry.size.width * self.middleSpacer)
                self.rightSideWaveView
                    .frame(height: self.height)
            }
            .position(x: geometry.size.width / 2, y: 10)
            .drawingGroup()
        }.edgesIgnoringSafeArea(.top)
    }
}



struct SharpRainbowView: View, Animatable{
    let waves: [SharpGradientBorder]
    var animation: Animation = Animation.linear(duration: 2).repeatForever(autoreverses: false)
    @State var started = false
    @State var rainbowPosition: CGFloat = 0
    
    var animationStartTime: Date? = nil
    init(rainbowColors: [Color],
        backgroundColor: Color = .clear,
        bottomRadius: CGFloat = 30,
        topRadius: CGFloat = 20,
        gradientLength: CGFloat = 5
    ){
        guard var lastColor = rainbowColors.last else {fatalError("no colors to display in rainbow")}
        var allWaves = [SharpGradientBorder]()
        for color in rainbowColors{
            let view = SharpGradientBorder(start: lastColor,
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
                            .animation(self.started ? self.animation : nil)
                            .positionOfSharp(waveNumber: ind,
                                             of: self.waves.count,
                                             frameWidth: geometry.size.width,
                                             inTime: self.rainbowPosition)
                            .animation(self.started ? self.animation : .default)
                        
                    }
                }
                .clipped()
            }
        }
        .onAppear(){
            self.started = true
            self.self.rainbowPosition = 1
        }

    }
}

struct AdvancedTimingRainbow_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedTimingRainbow()
    }
}
