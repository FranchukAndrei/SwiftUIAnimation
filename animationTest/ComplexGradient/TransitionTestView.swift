//
//  TransitionModifier.swift
//  animationTest
//
//  Created by Франчук Андрей on 21.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI


//extension AnyTransition {
//    static func overlayIn (anchor: UnitPoint) -> AnyTransition {
//        .modifier(
//            active: SpinTransitionModifier(angle: -90, anchor: anchor),
//            identity: SpinTransitionModifier(angle: 0, anchor: anchor))
//    }
//    static func overlayOut(anchor: UnitPoint) -> AnyTransition {
//        .modifier(
//            active: SpinTransitionModifier(angle: 90, anchor: anchor),
//            identity: SpinTransitionModifier(angle: 0, anchor: anchor))
//    }
//
//}


struct Truncate: AnimatableModifier {
    let leading: Bool
    var pct: CGFloat
    var waveGeometry: WaveGeometry
    var animatableData: CGFloat{
        get{pct}
        set{pct = newValue}
    }
    func body(content: Content) -> some View {
        GeometryReader{geometry in
            content
                .clipShape(self.getShape(in: geometry.size))
        }
    }
    func getShape(in size: CGSize) -> Path{
        let offset = waveGeometry.topRadius + waveGeometry.bottomRadius
        var start: CGFloat = pct
        var end: CGFloat = 1
        if leading{
            start = 0
            end = 1 - pct
        }
        let startPosition = max((size.width + offset * 2) * start - offset, 0)
        let endPosition = min((size.width + offset * 2) * end - offset, 1)
        let topLeading = CGPoint(x: startPosition, y: 0)
        let bottomLeading = CGPoint(x: startPosition, y: size.height)
        let topTrailing = CGPoint(x: size.width * end, y: 0)
        let bottomTrailing = CGPoint(x: size.width * end, y: size.height)
        return Path{path in
            path.move(to: topLeading)
            path.addLines([bottomLeading, bottomTrailing, topTrailing, topLeading])
        }
    }
}

extension AnyTransition {
    static func truncate(appeare: Bool = true, waveGeometry: WaveGeometry) -> AnyTransition{
        if appeare{
            return AnyTransition.modifier(
                active: Truncate(leading: true, pct: 1, waveGeometry: waveGeometry),//full truncate
                identity: Truncate(leading: true, pct: 0, waveGeometry: waveGeometry))//no truncate
        }else{
            return AnyTransition.modifier(
                active: Truncate(leading: false, pct: 1, waveGeometry: waveGeometry),//full truncate
                identity: Truncate(leading: false, pct: 0, waveGeometry: waveGeometry))//no truncate
        }
    }
}


struct TransitionTestView: View {
    @ObservedObject var animationHandler = AnimationHandler()
    let background: Color = .red
//    @State var pct: CGFloat = 0
    var body: some View {
        VStack{
            Spacer()
            RinbowBarHidable(background: background, animationHandler: animationHandler)
                .frame(height: 50)
            Button(action: {
                let control = TimingCurve.getControlPoints()
                let animation = Animation.timingCurve(Double(control.point1.x),
                                            Double(control.point1.y),
                                            Double(control.point2.x),
                                            Double(control.point2.y),
                                            duration: 2)
                withAnimation(animation){
                    self.animationHandler.isShown.toggle()
                }
            }){
                Text("toggle animation")
            }
        }
        .frame(width: 250)
    }
}

struct RinbowBarHidable: View{
    @ObservedObject var animationHandler: AnimationHandler
    let rainbow: SharpRainbowView
    init(colors: [Color]? = nil, background: Color, animationHandler: AnimationHandler){
        self.animationHandler = animationHandler
        var defaultColors: [Color] =  [.yellow, .blue, .green, .red]
        if let c = colors{
            defaultColors = c
        }
        self.rainbow = SharpRainbowView(rainbowColors: defaultColors,
                         animationHandler: animationHandler)
    }
    var body: some View{
        Group{
            if self.animationHandler.isShown{
                self.rainbow
                     .transition(.asymmetric(
                        insertion: .truncate(appeare: true, waveGeometry: animationHandler.waveGeometry),
                        removal: .truncate(appeare: false, waveGeometry: animationHandler.waveGeometry)
                    ))
            }
        }
    }
}
//struct TransitionRainbowView: View {
//    @ObservedObject var animationHandler: AnimationHandler
//    @State var hideStatusBar = false
//    @Environment(\.statusBarFrame) var statusBarframe: CGRect
//    let background: Color = .red
//    init(){
//        let animationHandler = AnimationHandler()
//        self.animationHandler = animationHandler
//    }
//    var body: some View {
//        ZStack{
//            VStack(spacing: 0){
//                HStack(spacing: 0){
//                    RinbowBarHidable(background: background, animationHandler: animationHandler)
//                }
//            }
//                .frame(width: statusBarframe.width, height: statusBarframe.height)
//                .edgesIgnoringSafeArea(.top)
//               // .position(CGPoint(x: statusBarframe.width / 2, y: statusBarframe.height / 2))
//                .background(background)
//            Rectangle()
//                .fill(Color.green)
//            .overlay(
//                VStack{
//                    Button("Toggle waves") {
//                        withAnimation(.linear(duration: 1)){
//                            if self.animationHandler.isStarted{
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
//                                    withAnimation(Animation.linear){//.delay(0.7
//                                        self.hideStatusBar = false
//                                    }
//                                }
//                            }else{
//                                self.hideStatusBar = true
//                            }
//                            self.animationHandler.isStarted.toggle()
//                        }
//
//                    }
//                    .statusBar(hidden: hideStatusBar)
//                }
//            )
//        }
//    }
//}

struct TransitionTestView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionTestView()
    }
}
