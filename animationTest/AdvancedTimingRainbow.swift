//
//  AdvancedTimingRainbow.swift
//  animationTest
//
//  Created by Франчук Андрей on 16.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct AdvancedTimingRainbow: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


struct SharpWavePosition: AnimatableModifier {
    
    
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
        let oneWaveWidth = CGFloat(1) / CGFloat(wavesCount)
        //creating manual timing curve to perform increacing velocity of waves
        let trimmingPath = Path(){path in
            let startPoint = CGPoint(x: -oneWaveWidth / 2, y: -oneWaveWidth / 2)
            let endPoint = CGPoint(x: 1 + oneWaveWidth / 2, y: 1 + oneWaveWidth / 2)
            let cp1 = CGPoint(x: 0.2, y: -oneWaveWidth / 2)//increase x for slower waves moving at the start
            let cp2 = CGPoint(x: 1 + oneWaveWidth / 2, y: 0.2)//decrease y for faster waves moving closer to end
            path.move(to: startPoint)
            path.addCurve(to: endPoint, control1: cp1, control2: cp2)
        }
        let initialPosition = oneWaveWidth / 2 + oneWaveWidth * CGFloat(waveInd)
        var currentPosition = initialPosition + time
        if currentPosition > 1 + oneWaveWidth / 2{
            currentPosition -= 1
        }
        //recalculate position using timing curve just like the built in animation do
        let curvePart = min(max(0, (currentPosition + oneWaveWidth / 2) / (1 + oneWaveWidth)), 1)//not less then 0 not more then 1
        let currentAnimatedPoint = trimmingPath.trimmedPath(from: 0, to: curvePart)
        var animatedPosition = currentPosition
        if let currentAnimatedPoint = currentAnimatedPoint.currentPoint{
            animatedPosition = currentAnimatedPoint.y
        }
        var frameWidth: CGFloat = oneWaveWidth
        var distanceToNextWave: CGFloat = 1
        let nextWavePosition = currentPosition + oneWaveWidth
        if nextWavePosition < 1 + oneWaveWidth / 2{
            let nextCurvePart = min(max(0, (nextWavePosition + oneWaveWidth / 2) / (1 + oneWaveWidth)), 1)//not less then 0 not more then 1

            guard let animationPoint = trimmingPath.trimmedPath(from: 0, to: nextCurvePart).currentPoint else{fatalError("wrong trimmCurve value")}
            let distance = animationPoint.y - animatedPosition
            distanceToNextWave = max(distance, -distance)
        }
        var distanceToPreviosWave: CGFloat = 1
        let previosWavePosition = currentPosition - oneWaveWidth
        if previosWavePosition > -oneWaveWidth / 2{
            //if this is the first wave, will get distance to next
            let previosCurvePart = min(max(0, (previosWavePosition + oneWaveWidth / 2) / (1 + oneWaveWidth)), 1)//not less then 0 not more then 1

            if let animationPoint = trimmingPath.trimmedPath(from: 0, to: previosCurvePart).currentPoint{
                let distance = animationPoint.y - animatedPosition
                distanceToPreviosWave = max(distance, -distance)
            }
        }
        
        //frameWidth = min(distanceToPreviosWave, distanceToNextWave) * 1.9
        frameWidth = 1
//        if frameWidth - min(distanceToPreviosWave, distanceToNextWave) > oneWaveWidth{
//            //this wave is near the border (last one or first one)
//            frameWidth = frameWidth * 1.5
//        }
        var copyFrameWidth = oneWaveWidth
        var startCopyAnimatedPosition = -oneWaveWidth / 2
        if animatedPosition > 1 - oneWaveWidth / 2{
            //this is the last wave and it partly went out of the frame border
            //we will add another copy of this view to the start, so rainbow will start again in a loop
            let startCopyPosition = (currentPosition - 1)
            let partforTrim = startCopyPosition + oneWaveWidth / 2
            if let currentAnimatedPoint = trimmingPath.trimmedPath(from: 0, to: partforTrim).currentPoint{
                startCopyAnimatedPosition = currentAnimatedPoint.y
            }
            let nextWavePosition = startCopyPosition + oneWaveWidth / 2
            let nextCurvePart = min(max(0, (nextWavePosition + oneWaveWidth / 2) / (1 + oneWaveWidth)), 1)//not less then 0 not more then 1

            if let animationPoint = trimmingPath.trimmedPath(from: 0, to: nextCurvePart).currentPoint{
                let nextWaveAnimatedPosition = animationPoint.y
                let distance = nextWaveAnimatedPosition - startCopyAnimatedPosition
                copyFrameWidth = max(distance, -distance)
            }

        }

        return  GeometryReader{geometry in
            if startCopyAnimatedPosition > -oneWaveWidth / 2 + 0.00001 {
                content
                    .frame(width: geometry.size.width * copyFrameWidth)
                    .clipped()
                    .position(x: geometry.size.width * startCopyAnimatedPosition,
                              y: geometry.size.height / 2)
                    .zIndex(Double(startCopyAnimatedPosition))
            }
            content
                .frame(width: geometry.size.width * frameWidth)
                .clipped()
                .position(x: geometry.size.width * animatedPosition,
                          y: geometry.size.height / 2)
                .zIndex(Double(animatedPosition))
        }
    }
}
extension View{
    func positionOfSharp(waveNumber waveInd: Int, of wavesCount: Int, inTime: CGFloat) -> some View {
        let time = inTime - CGFloat(Int(inTime))
        return self.modifier(WavePosition(waveInd: waveInd, wavesCount: wavesCount, time: time))
    }
}

struct SharpRainbowView: View, Animatable{
    let waves: [GradientBorder]
    //let backgroundColor: Color
    let fullRainbowAnimationDuration: CGFloat = 1
    @State var rainbowPosition: CGFloat = 0
    
    var animationStartTime: Date? = nil
    init(rainbowColors: [Color],
        backgroundColor: Color = .clear,
        bottomRadius: CGFloat = 10,
        topRadius: CGFloat = 10,
        gradientLength: CGFloat = 10
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
        VStack{
            ZStack{
                ForEach(self.waves.indices, id: \.self){ind in
                    self.waves[ind]
                        //.animation(self.animation)
                        .positionOfSharp(waveNumber: ind, of: self.waves.count, inTime: self.rainbowPosition// - CGFloat(Int(self.rainbowPosition))
                    )
                }
            }
            //to learn how it works comment following:
               // .clipped()
            .drawingGroup()
            //and uncomment following:
            Slider(value: self.$rainbowPosition, in: 0...3)
            Button(action:{
                
                var animation: Animation? = Animation.linear(duration: 2).repeatForever(autoreverses: false)
                if self.rainbowPosition == 0 {
                    withAnimation(animation){
                        self.rainbowPosition = 1
                    }
                }else{
                    self.rainbowPosition = 0
                }
            }){Text("startAnimation")}
        }
//        .onAppear(){
//            //self.animation =
////            withAnimation(self.animation){
//                self.rainbowPosition = 1
////            }
//        }
    }
}

struct AdvancedTimingRainbow_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedTimingRainbow()
    }
}
