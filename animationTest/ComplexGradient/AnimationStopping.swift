//
//  AnimationStopping.swift
//  animationTest
//
//  Created by Франчук Андрей on 18.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

class AnimationHandlerTest: ObservableObject{
    @Published var isStarted: Bool = true
}

struct AnimationStopping: View {
    @State var isStarted = true
    @ObservedObject var animationHandler = AnimationHandlerTest()
    var body: some View {
        VStack{
//            Spacer()
//            AnimatedRect(started: isStarted)
            Spacer()
            AnimatedRectObservedObject(animationHandler: self.animationHandler)
            Spacer()
            Button(action: {
                self.animationHandler.isStarted.toggle()
                self.isStarted.toggle()
            }){
                Text(isStarted ? "stop animation" : "start animation")
            }
        }
    }
}

struct AnimatedRect: View{
    @State var startTime: Date = Date()
    @State var angle: Double = 0
    @State var internalStarted: Bool
    var externalStarted = true
    var animation: Animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
    init(started externalStarted: Bool){
        self.externalStarted = externalStarted
        self._internalStarted = State(initialValue: !externalStarted)//forse to start animation
    }
   // var animationStopper: AnimationHandler
    var body: some View{
        //thats wrong. It just hiding a problem from SwiftUI not solving it
        DispatchQueue.main.async {
            if self.internalStarted && self.externalStarted == false{
                // print("stop animation")
                 let timePassed = Date().timeIntervalSince(self.startTime)
                 let fullSecondsPassed = Double(Int(timePassed))
                 let currentStage = timePassed - fullSecondsPassed
                 //self.animation = nil
                 self.internalStarted = false
                 let newAngle = self.angle - 90 + currentStage * 90
                 self.angle = newAngle
            }else if self.internalStarted == false && self.externalStarted {
             //    print("start animation")
                 
                 self.startTime = Date()
                 self.internalStarted = true
                 //self.animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
                 self.angle += 90
             }
        }
         
       return  VStack{
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 200)
                .rotationEffect(Angle(degrees: angle))
                .animation(internalStarted ? animation : .default)
            Spacer()
        }
    }
}

struct AnimatedRectObservedObject: View{
    @State var startTime: Date = Date()
    @State var angle: Double = 0
    //@State var isStarted: Bool
    @ObservedObject var animationHandler: AnimationHandlerTest
    var animation: Animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
    init(animationHandler: AnimationHandlerTest){
        self.animationHandler = animationHandler
        //self._isStarted = State(initialValue: animationHandler.isStarted)
    }
    var body: some View{
       return VStack{
            Rectangle()
                .fill(Color.green)
                .frame(width: 200, height: 200)
                .rotationEffect(Angle(degrees: angle))
                .animation(animationHandler.isStarted ? animation : .default)
            Spacer()
       }.onReceive(animationHandler.objectWillChange){
            let newValue = self.animationHandler.isStarted
            if newValue == false{
                 let timePassed = Date().timeIntervalSince(self.startTime)
                 let fullSecondsPassed = Double(Int(timePassed))
                 let currentStage = timePassed - fullSecondsPassed
                 let newAngle = self.angle - 90 + currentStage * 90
                withAnimation(.none){//not working:(((
                 self.angle = newAngle
                }
            }else {
                 self.startTime = Date()
                 self.angle += 90
             }
       }
       .onAppear{
            self.angle += 90
            self.startTime = Date()
        }
    }
}

struct AnimationStopping_Previews: PreviewProvider {
    static var previews: some View {
        AnimationStopping()
    }
}
