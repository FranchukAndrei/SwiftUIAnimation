//
//  SharpGradientBorder.swift
//  animationTest
//
//  Created by Франчук Андрей on 16.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct SharpGradientBorder: View {
    public let start: Color
    public let end: Color
    let bottomRadius: CGFloat
    let topRadius: CGFloat
    let gradientLength: CGFloat
//    let middleGradientStop: CGFloat = 0.3
    init(start: Color = .blue,
        end: Color = .red,
        bottomRadius: CGFloat,
        topRadius: CGFloat,
        gradientLength: CGFloat){
        self.start = start
        self.end = end
        self.bottomRadius = bottomRadius
        self.topRadius = topRadius
        self.gradientLength = gradientLength
    }
    var body: some View {
        GeometryReader{geometry in
            HStack(spacing: -1){
//                VStack(spacing: -1){
//                    Rectangle()
//                    .fill(LinearGradient(
//                        gradient: Gradient(stops: [.init(color: self.middle, location: 0),
//                                                   .init(color: self.start, location: self.middleGradientStop)]),
//                        startPoint: .init(x: 1, y: 0.5),
//                        endPoint: .init(x: 0, y: 0.5)))
//                    Rectangle()
//                        .fill(AngularGradient(gradient: Gradient(stops: [
//                                        .init(color: self.start, location: 0),
//                                        .init(color: self.middle, location: self.angularGradientMiddleStop(blockWidth: geometry.size.width - self.bottomRadius - self.topRadius)),
//                                        .init(color: self.end, location: 1)]),
//                                    center: .bottomLeading,
//                                    startAngle: self.directionTo(gradientPart: self.end, blockWidth: geometry.size.width - self.bottomRadius - self.topRadius),
//                                    endAngle: Angle(degrees: 360)))
//                        .frame(height: self.bottomRadius)
//                }
                SharpGradientView(start: self.start, end: self.end, bottomRadius: self.bottomRadius, topRadius: self.topRadius, gradientLength: self.gradientLength)
                    // .frame(width: self.bottomRadius + self.topRadius )
            }
        }
    }
}
struct GradientTail: View{
    var body: some View{
        Text("")
    }
}

struct SharpGradientView: View {
    let start: Color
    let middle: Color
    let middleGradientStop: CGFloat = 0.3
    let end: Color
//    let direction: Bool // true = right to left, fals = left to right
    let bottomRadius: CGFloat
    let topRadius: CGFloat
    let gradientLength: CGFloat
    init(start: Color, end: Color, bottomRadius: CGFloat , topRadius: CGFloat, //direction: Bool = true,
         gradientLength: CGFloat? = nil){
        self.start = start
        self.end = end
        self.middle = Color(averageOf: [start, end])

//        self.direction = direction
        self.topRadius = topRadius
        self.bottomRadius = bottomRadius
        if let length = gradientLength{
            self.gradientLength = length
        }else{
            self.gradientLength =  bottomRadius / 2
        }
        
    }
    var body: some View {
     //   GeometryReader{geometry in
            VStack(spacing: 0){
                Rectangle()
                    .fill(RadialGradient(gradient: Gradient(stops: [
                                .init(color: self.start, location: 0),
                                .init(color: self.middle, location: self.middleGradientStop),
                                .init(color: self.end, location: 1)]),
                             center: .bottomTrailing,
                             startRadius: self.topRadius,
                             endRadius: self.topRadius + self.gradientLength)
                    )
                    .frame(height: self.topRadius)
                 //   .position(x: geometry.size.width / 2, y: self.topRadius / 2)
                HStack(spacing: 0){
                    Rectangle()
                        .fill(self.end)
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: self.end, location: 0),
                                .init(color: self.middle, location: 1 - self.middleGradientStop),
                                .init(color: self.start, location: 1)]),
                            startPoint: .leading,
                            endPoint: .trailing))
                        .frame(width: self.gradientLength)
                    Spacer()
                        .frame(width: self.topRadius)
                }
                HStack(spacing: 0){
                    Rectangle()
                        .fill(self.end)
                    
                    GeometryReader{geometry in
                        Rectangle()
                            .fill(AngularGradient(gradient: Gradient(stops: [
                                            .init(color: self.end, location: 0),
                                            .init(color: self.middle, location: 1 - self.angularGradientMiddleStop(blockWidth: geometry.size.width)),
                                            .init(color: self.start, location: 1)]),
                                        center: .bottomLeading,
                                        startAngle: self.directionTo(gradientPart: self.start, blockWidth: geometry.size.width),
                                        endAngle: Angle(degrees: 360)))
                    }
//                    .frame(width: self.bottomRadius + self.gradientLength + self.topRadius)
                    Rectangle()
                        .fill(RadialGradient(gradient:  Gradient(stops: [
                                       .init(color: self.end, location: 0),
                                       .init(color: self.middle, location:  1 - self.middleGradientStop),
                                       .init(color: self.start, location: 1)]),
                                 center: .topLeading,
                                 startRadius: self.bottomRadius - self.gradientLength,
                                 endRadius: self.bottomRadius)
                        )
                        .frame(width: self.bottomRadius, height: self.bottomRadius)
                    Spacer()
                        .frame(width: self.topRadius)
//                    .position(x: geometry.size.width / 2, y: geometry.size.height - self.bottomRadius / 2)
                    //.offset(x: 0, y: -(geometry.size.height / 2 - self.topRadius / 2))
                }
                .frame(height: self.bottomRadius)
            }
                .leadingEdgeTrimmed(waveGeometry: WaveGeometry(topRadius: topRadius, bottomRadius: bottomRadius, gradientLength: gradientLength))
     //   }
    }

    func directionTo(gradientPart: Color, blockWidth: CGFloat) -> Angle{
        let angleOf = gradientAngles(blockWidth: blockWidth)
        var angle = Angle.zero
        switch gradientPart{
            case start: angle = angleOf.start
            case middle: angle = angleOf.middle
            case end: angle = angleOf.end
            default: fatalError("there is no gradient stop with that color: \(gradientPart)")
        }
        return angle
    }
    func angularGradientMiddleStop(blockWidth: CGFloat) -> CGFloat{
        let angleOf = gradientAngles(blockWidth: blockWidth)
        let result: CGFloat = CGFloat(angleOf.middle.degrees - angleOf.start.degrees) / CGFloat(angleOf.end.degrees - angleOf.start.degrees)
        return result
    }
    func gradientAngles(blockWidth: CGFloat) -> (start: Angle, middle: Angle, end: Angle){
        let blockHeight = self.bottomRadius
        let center = CGPoint(x: 0, y: blockHeight)
        let topRight = CGPoint(x: blockWidth, y: blockHeight - self.gradientLength)
        let topGradientStarts = CGPoint(x: blockWidth, y: blockHeight - self.gradientLength * (1 - self.middleGradientStop))
        let startAngle = center.radialDirection(to: topRight)
        let middleAngle = center.radialDirection(to: topGradientStarts)
        let endAngle = Angle(degrees: 360)
        return (start: startAngle, middle: middleAngle, end: endAngle)

    }

}

struct LeadingEdgeTrimmed: ViewModifier{
    let waveGeometry: WaveGeometry
    func body(content: Content) -> some View{
        GeometryReader{geometry in
            content
                .clipShape(self.leadingEdgeTrimmed(in: geometry.frame(in: .global)))
        }
    }
    func leadingEdgeTrimmed(in rect: CGRect) -> Path{
        return Path(){path in
            let topLeading = CGPoint(x: 0, y: 0)
            let topTrailing = CGPoint(x: rect.width, y: 0)
            let topArcCenter = CGPoint(x: rect.width, y: waveGeometry.topRadius)
//            let topArcEnd = CGPoint(x: rect.width - self.topRadius,
//                                    y: self.topRadius)
            let bottomArcCenter = CGPoint(x: rect.width - waveGeometry.topRadius - waveGeometry.bottomRadius,
                                          y: rect.height - waveGeometry.bottomRadius)
            let bottomArcStart = CGPoint(x: rect.width - waveGeometry.topRadius, y: waveGeometry.topRadius)
//            let arcCrossBottom = CGFloat(sqrt(pow(self.bottomRadius + gradientLength, 2) - pow(self.bottomRadius, 2)))
            
//            let bottomArcEnd = CGPoint(x: bottomArcCenter.x + arcCrossBottom, y: rect.height)
            let bottomLeading = CGPoint(x: 0, y: rect.height)
            path.move(to: topLeading)
            path.addLine(to: topTrailing)
            path.addArc(center: topArcCenter, radius: waveGeometry.topRadius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180), clockwise: true)//on our apinion it would be counterclockwise but apple got reflected coordinate system, so it isnt
            path.addLine(to: bottomArcStart)
            path.addArc(center: bottomArcCenter, radius: waveGeometry.bottomRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)//the same here
            path.addLine(to: bottomLeading)
            path.addLine(to: topLeading)
        }
    }
}
extension View{
    func leadingEdgeTrimmed(waveGeometry: WaveGeometry) -> some View{
        self.modifier(LeadingEdgeTrimmed(waveGeometry: waveGeometry))
    }
}
extension CGPoint{
    func radialDirection(to point: CGPoint) -> Angle{
        let deltaX =  point.x - self.x
        let deltaY =  point.y - self.y
        var angle = Angle(degrees: 0)
        if deltaX == 0{
            if deltaY > 0{
                angle = Angle(degrees: 90)
            }else{
                angle = Angle(degrees: 270)
            }
        }else if deltaY == 0{
            if deltaX > 0{
                angle = Angle(degrees: 0)
            }else{
                angle = Angle(degrees: 180)
            }
        }else if deltaX > 0 && deltaY > 0{
                angle = Angle(radians: atan(Double(deltaY / deltaX)))
        }else if deltaX > 0 && deltaY < 0{
                angle = Angle(degrees: 270) + Angle(radians: atan(Double(deltaX / -deltaY)))
        }else if deltaX < 0 && deltaY > 0{
                angle = Angle(degrees: 90) + Angle(radians: atan(Double(-deltaX / deltaY)))
        }else if deltaX < 0 && deltaY < 0{
                angle = Angle(degrees: 180) + Angle(radians: atan(Double(deltaY / deltaX)))
        }
        return angle
    }
}


struct SharpGradientBorder_Previews: PreviewProvider {
    static var previews: some View {
        SharpGradientBorder(start: .red, end: .yellow, bottomRadius: 20, topRadius: 10, gradientLength: 10)
        .frame(width: 200, height: 40)
    }
}
