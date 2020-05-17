//
//  SharpPositionModifier.swift
//  animationTest
//
//  Created by Франчук Андрей on 17.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI


struct SharpWavePosition: AnimatableModifier {
    
    
    let waveInd: Int
    let wavesCount: Int
    let frameWidth: CGFloat
    var time: CGFloat
    private let timing: TimingCurve
    public var animatableData: Double {
        get { Double(time) }
        set {
            self.time = CGFloat(newValue)
        }
    }
    init(waveInd: Int, wavesCount: Int, frameWidth: CGFloat, time: CGFloat){
        self.frameWidth = frameWidth
        self.waveInd = waveInd
        self.wavesCount = wavesCount
        self.time = time
        let oneWaveWidth = CGFloat(1) / CGFloat(wavesCount)
        self.timing = TimingCurve.superEaseOut(duration: 1, reserve: oneWaveWidth / 2)
    }
    private struct TimingCurve{
        let trimmingCurve: Path
        let reserve: CGFloat
        let duration: CGFloat
        
        init(from start: CGPoint, to end: CGPoint, cp1: CGPoint, cp2: CGPoint, reserve: CGFloat? = nil){
            var rStart: CGPoint? = nil
            var rEnd: CGPoint? = nil
            self.duration = end.x - start.x
            if let r = reserve{
                rStart = CGPoint(x: start.x - r, y : start.y - r)
                rEnd = CGPoint(x: end.x + r, y: end.y + r)
                self.reserve = r
            }else{
                self.reserve = 0
            }
            self.trimmingCurve = Path(){path in
                if let rs = rStart{
                    path.move(to: rs)
                    path.addLine(to: start)
                }else{
                    path.move(to: start)
                }
                path.addCurve(to: end, control1: cp1, control2: cp2)
                if let re = rEnd{
                    path.addLine(to: re)
                }
            }
        }
        //gets actual timing of given value according to trimming curve
        func getActual(of position: CGFloat) -> CGFloat{
            let correctPosition = max(min(position, self.duration + self.reserve), -self.reserve)// -reserve <= correctPosition <= duration+reserve
            
            if correctPosition < -reserve + 0.0000001{
                let reversedCurve = Path(UIBezierPath(cgPath: self.trimmingCurve.cgPath).reversing().cgPath)
                //trim to start point is impossible, so reverce the curve and get last point
                guard let point = reversedCurve.currentPoint else{fatalError("cant get current timing curve start point")}
                return point.y
            }
            let curvePart: CGFloat = max(0, min(1, (correctPosition + self.reserve) / (self.duration + self.reserve * 2)))
            // 0 <= curvePart <= 1
            guard let point = trimmingCurve.trimmedPath(from: 0, to: curvePart).currentPoint else{fatalError("cant get current timing curve point at \(position)")}
            return point.y
        }
        static func superEaseOut(duration: CGFloat = 1, reserve: CGFloat = 0) -> TimingCurve{
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: duration, y: duration)
            let cp1 = CGPoint(x: 0.2 * duration, y: -reserve)//increase x for slower waves moving at the start
            let cp2 = CGPoint(x: duration, y: 0.4)//decrease y for faster waves moving closer to end
            return TimingCurve(from: startPoint, to: endPoint, cp1: cp1, cp2: cp2, reserve: reserve)
        }
    }
    static func calculate(forWave: Int, ofWaves: Int, overTime: CGFloat) -> CGFloat{
        let time = overTime - CGFloat(Int(overTime))
        let oneWaveWidth = CGFloat(1) / CGFloat(ofWaves)
        let initialPosition = oneWaveWidth * CGFloat(forWave)
        let currentPosition = initialPosition + time
        let fullRounds = Int(currentPosition)
        var result = currentPosition - CGFloat(fullRounds)
        if fullRounds > 0 && result == 0{
            // at the end of the round it should be 1, not 0
            result = 1
        }
 //       print("wave \(forWave) in time \(overTime) was at position \(result)")
        return result
    }

    func body(content: Content) -> some View {
        let oneWaveWidth = CGFloat(1) / CGFloat(wavesCount)
        //let frameWidthWithReserve = self.frameWidth * (1 + oneWaveWidth)
        let currentTime = time - CGFloat(Int(time))
        let currentPosition = SharpWavePosition.calculate(forWave: waveInd, ofWaves: wavesCount, overTime: currentTime)
        var thisIsFirstWave = false
        if currentPosition < oneWaveWidth{
            thisIsFirstWave = true
        }
        //recalculate position using timing curve just like the built in animation do
        let animatedPosition = timing.getActual(of: currentPosition)
        print("wave \(waveInd) at time \(currentPosition) position \(animatedPosition)")
        return
            Group{
                content
                    .animation(nil)
                    .zIndex(-Double(animatedPosition))
                    .offset(x: animatedPosition * self.frameWidth * 1.3 - self.frameWidth,// + 20% to make wave pass through trailing edge and only then disapeare
                            //to watch how waves move uncoment this
                           // y: CGFloat(self.waveInd * 20))
                        y: 0)
                if thisIsFirstWave{
                    content
                        .transition(.identity)
                        .zIndex(-2)
                        .offset(x: self.frameWidth / CGFloat(3),
                                //to watch how waves move uncoment this
                         //       y: CGFloat(-20))
                            y: 0)

                }
            }
        
    }
}

extension View{
    func positionOfSharp(waveNumber waveInd: Int, of wavesCount: Int, frameWidth: CGFloat, inTime: CGFloat) -> some View {
        return self.modifier(SharpWavePosition(waveInd: waveInd, wavesCount: wavesCount, frameWidth: frameWidth, time: inTime))
    }
}


struct SharpPositionModifier_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedTimingRainbow()
    }
}
