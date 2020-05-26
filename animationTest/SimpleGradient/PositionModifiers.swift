//
//  PositionModifiers.swift
//  animationTest
//
//  Created by Франчук Андрей on 17.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI


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
            }
            content
                .animation(nil)
                .position(x: geometry.size.width * currentPosition,
                          y: geometry.size.height / 2)
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

struct PositionModifiers_Previews: PreviewProvider {
    static var previews: some View {
        TestRainbowView()
    }
}
