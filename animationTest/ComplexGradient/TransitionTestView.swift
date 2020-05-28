//
//  TransitionModifier.swift
//  animationTest
//
//  Created by Франчук Андрей on 21.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct Truncate: AnimatableModifier {
    let leading: Bool
    let background: Color
    var pct: CGFloat
    var animationState: AnimationHandler
    let reflected: Bool
    var animatableData: CGFloat{
        get{pct}
        set{
            pct = newValue
            if leading{
                if newValue < 0.001{
                    if animationState.currentTransitionInBaseColor != .clear{
                        animationState.currentTransitionInBaseColor = .clear
                    }
                }else if newValue > 0.999{
                    if animationState.currentTransitionInBaseColor != animationState.currentWaveBaseColor{
                        animationState.currentTransitionInBaseColor = animationState.currentWaveBaseColor
                    }
                }
            }else{
                if newValue > 0.999{
                    if animationState.currentTransitionOutBaseColor != .clear{
                        animationState.currentTransitionOutBaseColor = .clear
                    }
                }else if newValue < 0.001{
                    if animationState.currentTransitionOutBaseColor != animationState.currentWaveBaseColor{
                        animationState.currentTransitionOutBaseColor = animationState.currentWaveBaseColor
                    }
                }

            }
        }
    }
    func body(content: Content) -> some View {
        let waveGeometry = self.animationState.waveGeometry
        let offset = waveGeometry.bottomRadius + waveGeometry.topRadius
        var startingColor = self.background
        if let color = animationState.rainbowColors.first{
            startingColor = color
        }
        var nextColor = startingColor
        if let ind = animationState.rainbowColors.firstIndex(of: animationState.currentTransitionOutBaseColor){
            var nextInd = animationState.rainbowColors.index(before: ind)
            if animationState.rainbowColors.indices.contains(nextInd) == false{
                guard let firtInd = animationState.rainbowColors.indices.last else{fatalError("no index in colors array")}
                nextInd = firtInd
            }
            nextColor = animationState.rainbowColors[nextInd]
        }
        return GeometryReader{geometry in
            ZStack{
                
                content
                    .clipShape(self.getShape(in: geometry.size))
                
                if self.leading{
                    HStack(spacing: 0){
                        ZStack{
                            SharpGradientBorder(start: self.background,
                                                end: startingColor,
                                                bottomRadius: waveGeometry.bottomRadius,
                                                topRadius: waveGeometry.topRadius,
                                                gradientLength: waveGeometry.gradientLength)
                                .frame(width: offset * 2)
                                .position(x: offset, y: geometry.size.height / 2)
                            SharpGradientBorder(start: startingColor,
                                                end: self.animationState.currentTransitionInBaseColor,
                                                bottomRadius: waveGeometry.bottomRadius,
                                                topRadius: waveGeometry.topRadius,
                                                gradientLength: waveGeometry.gradientLength)
                                .frame(width: offset)
                            .position(x: offset / 2, y: geometry.size.height / 2)
                        }
                        Spacer()
                        
                    }
                        .transition(.identity)
                        .rotation3DEffect(
                            self.reflected
                                ? Angle(degrees: 180)
                                : Angle.zero,
                            axis: (x: 0, y: 1, z: 0))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: self.reflected
                            ? CGFloat(offset) - CGFloat(geometry.size.width + offset) * CGFloat(1 - self.pct)
                            : -CGFloat(offset) + CGFloat(geometry.size.width + offset) * CGFloat(1 - self.pct),
                                //y: -80)
                                y: 0)
                        .animation(nil)
                        .clipped()
                }else{
                    HStack(spacing: -1){
                        Spacer()
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [nextColor, self.background]),
                                                 startPoint: .trailing,
                                                 endPoint: .leading))
                            .frame(width: offset)
                        SharpGradientBorder(start: self.animationState.currentTransitionOutBaseColor,
                                            end: nextColor,
                                            bottomRadius: waveGeometry.bottomRadius,
                                            topRadius: waveGeometry.topRadius,
                                            gradientLength: waveGeometry.gradientLength)
                            .frame(width: offset * 1.5)

                    }
                        .transition(.identity)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .rotation3DEffect(
                            self.reflected
                                ? Angle(degrees: 180)
                                : Angle.zero,
                            axis: (x: 0, y: 1, z: 0))

                        .offset(x: self.reflected
                            ? (geometry.size.width) - CGFloat(geometry.size.width + offset * 2) * self.pct
                            : -(geometry.size.width) + CGFloat(geometry.size.width + offset * 2) * self.pct,
                                //y: -40)
                                y: 0)
                        .animation(nil)
                        .clipped()
                    
                }
            }
        }
    }
    func getShape(in size: CGSize) -> Path{
        let waveGeometry = self.animationState.waveGeometry
        let offset = waveGeometry.topRadius + waveGeometry.bottomRadius
        var start: CGFloat = pct
        var end: CGFloat = 1
        if leading{
            start = 0
            end = 1 - pct
        }
        var startPosition = min(max((size.width + offset * 2) * start - offset, 0), size.width)
        var endPosition = max(min((size.width + offset) * end - offset, size.width), 0)
        if reflected{
            startPosition = size.width - startPosition
            endPosition = size.width - endPosition
        }
//        print("leading: \(leading): start = \(startPosition), end: \(endPosition)")
        let topLeading = CGPoint(x: startPosition, y: 0)
        let bottomLeading = CGPoint(x: startPosition, y: size.height)
        let topTrailing = CGPoint(x: endPosition, y: 0)
        let bottomTrailing = CGPoint(x: endPosition, y: size.height)
        return Path{path in
            path.move(to: topLeading)
            path.addLines([bottomLeading, bottomTrailing, topTrailing, topLeading])
        }
    }
}

extension AnyTransition {
    static func truncate(appeare: Bool = true, background: Color, animationState: AnimationHandler, reflected: Bool = false) -> AnyTransition{
        if appeare{
            return AnyTransition.modifier(
                active: Truncate(leading: true, background: background, pct: 1, animationState: animationState, reflected: reflected),//full truncate
                identity: Truncate(leading: true, background: background, pct: 0, animationState: animationState, reflected: reflected))//no truncate
        }else{
            return AnyTransition.modifier(
                active: Truncate(leading: false, background: background, pct: 1, animationState: animationState, reflected: reflected),//full truncate
                identity: Truncate(leading: false, background: background, pct: 0, animationState: animationState, reflected: reflected))//no truncate
        }
    }
}


struct RainbowTransitionView: View {
    var isShown: Bool
    @ObservedObject var animationHandler: AnimationHandler
    @Environment(\.statusBarFrame) var statusBarframe: CGRect
    let background: Color
    let animation = Animation.timingCurve(Double(TimingCurve.control.point1.x),
                                Double(TimingCurve.control.point1.y),
                                Double(TimingCurve.control.point2.x),
                                Double(TimingCurve.control.point2.y),
                                duration: 2)
    var body: some View {
        VStack(spacing: 0){
            HStack(spacing: 0){
                if isShown{
                    SharpRainbowView(animationHandler: animationHandler)
                     .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
                     .transition(AnyTransition.asymmetric(
                        insertion: AnyTransition.truncate(appeare: true, background: self.background, animationState: animationHandler, reflected: true).animation(animation),
                        removal: AnyTransition.truncate(appeare: false, background: self.background, animationState: animationHandler, reflected: true).animation(animation))
                        )
                        
                }
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 175)
                if isShown{
                    SharpRainbowView(animationHandler: animationHandler)
                        .transition(AnyTransition.asymmetric(
                           insertion: AnyTransition.truncate(appeare: true, background: self.background, animationState: animationHandler).animation(animation),
                           removal: AnyTransition.truncate(appeare: false, background: self.background, animationState: animationHandler).animation(animation))
                        )
                        
                }
            }
            .frame(width: statusBarframe.width, height: 30)
            StatusBarHider(isShown: isShown)
        }
            .background(background)
            .frame(width: statusBarframe.width, height: statusBarframe.height)
            .edgesIgnoringSafeArea(.top)
            .position(CGPoint(x: statusBarframe.width / 2, y: statusBarframe.height / 2))

    }
//    func getRemoveDelay() -> Double{
//        let currentPosition = Double(animationHandler.currentAnimationPosition)
//        let oneWavePeriod = 1 / Double(animationHandler.rainbowColors.count)
//        let wavesStarted = Int(currentPosition / oneWavePeriod)
//        let wait = oneWavePeriod * Double(wavesStarted + 1) - currentPosition - oneWavePeriod * 0.4
//        print("current time: \(currentPosition), lastWaveStarted: \(oneWavePeriod * Double(wavesStarted)) wait: \(wait)")
//        return max(wait, 0)
//    }

}
struct StatusBarHider: View{
    var isShown: Bool
    @State var internalIsShown = true
    var body: some View{
        if isShown == false && self.internalIsShown == true{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6){
                self.internalIsShown = self.isShown
            }
        }else if isShown == true && self.internalIsShown == false{
            DispatchQueue.main.async(){
                self.internalIsShown = self.isShown
            }
        }
        return Spacer()
            .statusBar(hidden: internalIsShown)
            .animation(Animation.linear(duration: 0.4))
    }
}
struct TransitionRainbowView: View {
    @ObservedObject var animationHandler = AnimationHandler()
    @State var isShown = false
    let background: Color = .white
    init(){
        let animationHandler = AnimationHandler()
        self.animationHandler = animationHandler
    }
    var body: some View {
        ZStack{
            RainbowTransitionView(isShown: isShown, animationHandler: animationHandler, background: background)
            Rectangle()
                .fill(background)
            .overlay(
                VStack{
                    Button("Toggle waves"){
                        withAnimation{
                            self.isShown.toggle()
                        }

                    }
                }
            )
        }
    }
}

//
//struct TransitionTestView: View {
//    @ObservedObject var animationHandler = AnimationHandler()
//    let background: Color = .green
//    @State var isShown = false
//    var body: some View {
//        VStack{
//            Spacer()
//            if isShown{
//                SharpRainbowView(animationHandler: animationHandler)
//                     .transition(.asymmetric(
//                        insertion: .truncate(appeare: true, background: self.background, animationState: animationHandler),
//                        removal: .truncate(appeare: false, background: self.background, animationState: animationHandler)
//                    ))
//
//            }
//
//            Button(action: {
//                let animation = Animation.timingCurve(Double(TimingCurve.control.point1.x),
//                                            Double(TimingCurve.control.point1.y),
//                                            Double(TimingCurve.control.point2.x),
//                                            Double(TimingCurve.control.point2.y),
//                                            duration: 2)
//                withAnimation(animation
//                //    .delay(Double(1 - self.animationHandler.currentAnimationPosition))
//                ){
//                    self.isShown.toggle()
//                }
//            }){
//                Text("toggle animation")
//            }
//            .frame(height: 50)
//        }
//        .frame(width: 250, height: 100)
//        .background(background)
//    }
//}


struct TransitionTestView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionRainbowView()
        //TransitionTestView()
    }
}
