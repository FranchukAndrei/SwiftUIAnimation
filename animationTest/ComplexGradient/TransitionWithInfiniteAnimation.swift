//
//  TransitionWithInfiniteAnimation.swift
//  animationTest
//
//  Created by Франчук Андрей on 27.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI
class SomeObservedObject: ObservableObject{
    @Published var text = "text"
}
struct RainbowTransitionTest: View{
    var animationHandler = AnimationHandler()
    @State var isShown = false
    let background = Color.white
    let animation = Animation.timingCurve(Double(TimingCurve.control.point1.x),
                                Double(TimingCurve.control.point1.y),
                                Double(TimingCurve.control.point2.x),
                                Double(TimingCurve.control.point2.y),
                                duration: 1)

    var body: some View{
        VStack{
            Group{
                if isShown{
                    SharpRainbowView(animationHandler: animationHandler)
                        .transition(AnyTransition.asymmetric(
                           insertion: AnyTransition.truncate(appeare: true, background: self.background, animationState: animationHandler).animation(animation),
                           removal: AnyTransition.truncate(appeare: false, background: self.background, animationState: animationHandler).animation(animation))
                        )
                    
                }else{
                    Spacer()
                }
            }

            Text("toggle animation").onTapGesture {
                withAnimation(){
                    var delay: Double = 0
                    if self.isShown{
                        let waveChangeTime: Double = Double(1) /  Double(self.animationHandler.rainbowColors.count)
                        let currentTime = Double(self.animationHandler.currentAnimationPosition)
                        let wavesPassed = Double(Int(currentTime / waveChangeTime))
                        delay =  (wavesPassed + 1) * waveChangeTime - currentTime
                        delay = max(delay - 0.05, 0)
                        print("currentTime: \(currentTime); delay \(delay)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.isShown.toggle()
                    }
                }
            }
        }
    }
}

struct TransitionWithInfiniteAnimation_Previews: PreviewProvider {
    static var previews: some View {
        RainbowTransitionTest().frame(height: 200)
    }
}
