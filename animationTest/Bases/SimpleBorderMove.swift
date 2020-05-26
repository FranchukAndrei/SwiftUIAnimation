//
//  SimpleBorderMove.swift
//  animationTest
//
//  Created by Франчук Андрей on 23.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct SimpleBorderMove: View{
    var body: some View{
         SimpleView()
            .frame(height: 300)
    }
}

struct SimpleView: View{
    @State var position: CGFloat = 0
    @State var height: CGFloat = 0
    var body: some View{
        VStack{
            ZStack{
                Rectangle()
                    .fill(Color.gray)
                BorderView(position: position, height: height)
            }
            HStack{
                VStack{
                    HStack{
                        Slider(value: self.$position, in: 0...1)
                        Button(action: {
                            withAnimation(.linear(duration: 1)){
                                self.position = 0
                            }
                        }){
                            Text("X")
                        }
                    }
                    HStack{
                        Slider(value: self.$height, in: 0...1)
                        Button(action: {
                            withAnimation(.linear(duration: 1)){
                                self.height = 0
                            }
                        }){
                            Text("X")
                        }
                    }
                }
                Button(action: {
                    withAnimation(.linear(duration: 1)){
                        self.position = CGFloat.random(in: 0..<1)
                        print("new position is \(self.position)")
                        self.height = CGFloat.random(in: 0..<1)
                        print("new height is \(self.height)")
                    }
                }){
                    Text("Randomize")
                }.background(Color.gray)

            }
        }
    }
}


struct BorderView: View{
    //doesnt work. View is not Inherite Animatable:  https://developer.apple.com/documentation/swiftui/animatable
    public var animatableData: CGFloat {
        get {
            print("Reding position: \(position)")
            return self.position
        }
        set {
            self.position = newValue
            print("setting position: \(position)")
        }
    }
    var position: CGFloat
    var height: CGFloat
    let borderWidth: CGFloat
    init(position: CGFloat, borderWidth: CGFloat = 10, height: CGFloat = 1){
        self.position = position
        self.borderWidth = borderWidth
        self.height = height
        print("BorderView init")
    }
    var body: some View{
 //       GeometryReader{geometry in
            Rectangle()
                .fill(Color.green)
                .frame(width: self.borderWidth)
                //.offset(x: self.getXOffset(inSize: geometry.size), y: 0)
                //.borderIn(position: position)
                .twoParameterBorder(position: position, height: height)
//                .twoParameterBorder(height: height, position: position)
//        }
    }
//    func getXOffset(inSize: CGSize) -> CGFloat{
//        print("calculating position: \(position)")
//        return -inSize.width / 2 + inSize.width * position
//    }
}

struct BorderPosition: AnimatableModifier {//ViewModifier
    var position: CGFloat
    let startDate: Date = Date()
    public var animatableData: CGFloat {
        get {
            print("animation: reading position: \(position) at time \(Date().timeIntervalSince(startDate))")
            return position
        }
        set {
            print("animation: setting position: \(newValue) at time \(Date().timeIntervalSince(startDate))")
            position = newValue
        }
    }

    init(position: CGFloat){
        self.position = position
        print("modifier init with position \(position)")
    }
    func body(content: Content) -> some View {
        GeometryReader{geometry in
            content
            .animation(nil)
            .offset(x: self.getXOffset(inSize: geometry.size), y: 0)
        }
    }
    func getXOffset(inSize: CGSize) -> CGFloat{
        let p = position
        let offset = -inSize.width / 2 + inSize.width * p
        print("at position  \(p) offset is \(offset)")
        return offset
    }
}

extension View{
    func borderIn(position: CGFloat) -> some View{
        self.modifier(BorderPosition(position: position))
    }
}
extension View{
//    func twoParameterBorder(height: CGFloat, position: CGFloat) -> some View{
//        self.modifier(TwoParameterBorder(height: height, position: position))
//    }
    func twoParameterBorder(position: CGFloat, height: CGFloat) -> some View{
        self.modifier(TwoParameterBorder(position: position, height: height))
    }
}

struct TwoParameterBorder: AnimatableModifier {
//    var position: CGFloat
//    var height: CGFloat
    let id = UUID()
    var height: CGFloat
    var position: CGFloat
    let startDate: Date = Date()
//    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
//        get {
//           print("animation read position: \(position), height: \(height)")
//           return AnimatablePair(position, height)
//        }
//        set {
//            self.position = newValue.first
//            self.height = newValue.second
//            print("animating position: \(position); height: \(height)")
//        }
//    }
    public var animatableData: MyAnimatableVector{
        get {
            print("read position: \(position), height: \(height) at time: \(Date().timeIntervalSince(startDate)) (id: \(self.id.debugDescription))")
            return MyAnimatableVector(position: position, height: height)
        }
        set {
            self.position = newValue.position
            self.height = newValue.height
            print("set position: \(position); height: \(height) at time: \(Date().timeIntervalSince(startDate)) (id: \(self.id.debugDescription))")
        }
    }
    
    init(position: CGFloat, height: CGFloat){
        self.position = position
        self.height = height
//        print("TwoParameterBorder modifier init with position \(position)")
    }

    init(height: CGFloat, position: CGFloat){
        self.position = position
        self.height = height
//        print("TwoParameterBorder modifier init with position \(position)")
    }
    func body(content: Content) -> some View {
     //   usleep(100000) // 0.1 sec

        return GeometryReader{geometry in
            content
                .animation(nil)
                .offset(x: -geometry.size.width / 2 + geometry.size.width * self.position, y: 0)
                .frame(height: self.height * (geometry.size.height - 20) + 20)
        }
    }
}

struct SimpleBorderMove_Previews: PreviewProvider {
    static var previews: some View {
        SimpleBorderMove()
            .frame(height: 300)
    }
}
//final class  MyAnimatableVector: VectorArithmetic{
struct MyAnimatableVector: VectorArithmetic{
    var position: CGFloat
    var height: CGFloat

    static func - (lhs: MyAnimatableVector, rhs: MyAnimatableVector) -> Self {
        var new = Self.init()
        new.position = lhs.position - rhs.position
        new.height = lhs.height - rhs.height
        print("\(lhs.position) - \(rhs.position) = \(new.position)")
        print("\(lhs.height) - \(rhs.height) = \(new.height)")
        return new
    }
    
    static func -= (lhs: inout MyAnimatableVector, rhs: MyAnimatableVector) {
        lhs = lhs - rhs
    }

    static func + (lhs: MyAnimatableVector, rhs: MyAnimatableVector) -> Self {
        var new = Self.init()
        new.position = lhs.position + rhs.position
        new.height = lhs.height + rhs.height
        print("\(lhs.position) + \(rhs.position) = \(new.position)")
        print("\(lhs.height) + \(rhs.height) = \(new.height)")
        return new
    }
//
    static func += (lhs: inout MyAnimatableVector, rhs: MyAnimatableVector) {
        lhs = lhs + rhs
    }

    mutating
    func scale(by rhs: Double) {
        let newPosition = self.position * CGFloat(rhs)
        let newHeight = self.height * CGFloat(rhs)
        print("\(position) * \(rhs) = \(newPosition)")
        print("\(height) * \(rhs) = \(newHeight)")
        self.position = newPosition
        self.height = newHeight
    }
    
    var magnitudeSquared: Double{
        get{
            let result =  Double(self.position * self.position) + Double(self.height * self.height)
            return result
        }
    }
    
    static var zero: Self{
        get{Self.init()}
    }
    
    static func == (lhs: MyAnimatableVector, rhs: MyAnimatableVector) -> Bool {
        let result = lhs.position == rhs.position && lhs.height == rhs.height
        return result
    }
    
    
    init(position: CGFloat, height: CGFloat){
        self.position = position
        self.height = height
    }
   // required
    init(){
        self.position = 0
        self.height = 0
    }
}

