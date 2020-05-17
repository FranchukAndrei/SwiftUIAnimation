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
    let middle: Color
    public let end: Color
    let bottomRadius: CGFloat
    let topRadius: CGFloat
    let gradientLength: CGFloat
    init(start: Color = .blue,
        end: Color = .red,
        bottomRadius: CGFloat = 70,
        topRadius: CGFloat = 100,
        gradientLength: CGFloat = 160){
        self.start = start
        self.end = end
        self.middle = Color(averageOf: [start, end])
        self.bottomRadius = bottomRadius
        self.topRadius = topRadius
        self.gradientLength = gradientLength
    }
    var body: some View {

        HStack(spacing: -1){
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(stops: [.init(color: middle, location: 0),
                                                .init(color: start, location: 0.3)]),
                    startPoint: .init(x: 1, y: 0.5),
                    endPoint: .init(x: 0, y: 0.4)))//should make some calculations for different frame sizes, but im so lazy...
            SharpGradientView(start: middle, end: end, bottomRadius: bottomRadius, topRadius: topRadius, gradientLength: gradientLength)
                .frame(width: bottomRadius + topRadius + gradientLength)
        }
    }
}

struct SharpGradientView: View {
    let start: Color
    let end: Color
    let direction: Bool // true = right to left, fals = left to right
    let bottomRadius: CGFloat
    let topRadius: CGFloat
    let gradientLength: CGFloat
    init(start: Color, end: Color, bottomRadius: CGFloat = 20, topRadius: CGFloat = 10, direction: Bool = true, gradientLength: CGFloat? = nil){
        self.start = start
        self.end = end
        self.direction = direction
        self.topRadius = topRadius
        self.bottomRadius = bottomRadius
        if let length = gradientLength{
            self.gradientLength = length
        }else{
            self.gradientLength = min(topRadius, bottomRadius)
        }
        
    }
    var body: some View {
        GeometryReader{geometry in
            ZStack{
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(stops:
                            [.init(color: self.start, location: (self.bottomRadius / geometry.size.width)),
                             .init(color: self.end, location: (self.bottomRadius + self.gradientLength) / geometry.size.width)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing))
                   // .frame(width: self.gradientLength)
                Rectangle()
                    .fill(RadialGradient(gradient: Gradient(colors: [self.start, self.end]),
                                         center: .topLeading,
                                         startRadius: self.bottomRadius,
                                         endRadius: self.bottomRadius + self.gradientLength)

                    )
                    .frame(height: self.bottomRadius)
                    .offset(x: 0, y: geometry.size.height / 2 - self.bottomRadius / 2)
                Rectangle()
                    .fill(RadialGradient(gradient: Gradient(colors: [self.start, self.end]),
                                         center: .bottomTrailing,
                                         startRadius: self.topRadius + self.gradientLength,
                                         endRadius: self.topRadius)

                    )
                    .frame(height: self.topRadius)
                    .offset(x: 0, y: -(geometry.size.height / 2 - self.topRadius / 2))
            }.clipShape(self.leadingEdgeTrimmed(in: geometry.frame(in: .global)))
        }
    }
    func leadingEdgeTrimmed(in rect: CGRect) -> Path{
        return Path(){path in
            let topLeading = CGPoint(x: 0, y: 0)
            let topTrailing = CGPoint(x: rect.width, y: 0)
            let topArcCenter = CGPoint(x: rect.width, y: self.topRadius)
//            let topArcEnd = CGPoint(x: rect.width - self.topRadius,
//                                    y: self.topRadius)
            let bottomArcCenter = CGPoint(x: rect.width - self.topRadius - self.gradientLength - self.bottomRadius,
                                          y: rect.height - self.bottomRadius)
            let bottomArcStart = CGPoint(x: rect.width - self.topRadius, y: self.topRadius)
//            let arcCrossBottom = CGFloat(sqrt(pow(self.bottomRadius + gradientLength, 2) - pow(self.bottomRadius, 2)))
            
//            let bottomArcEnd = CGPoint(x: bottomArcCenter.x + arcCrossBottom, y: rect.height)
            let bottomLeading = CGPoint(x: 0, y: rect.height)
            path.move(to: topLeading)
            path.addLine(to: topTrailing)
            path.addArc(center: topArcCenter, radius: topRadius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180), clockwise: true)//on our apinion it would be counterclockwise but apple got reflected coordinate system, so it isnt
            path.addLine(to: bottomArcStart)
            path.addArc(center: bottomArcCenter, radius: bottomRadius + gradientLength, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)//the same here
            path.addLine(to: bottomLeading)
            path.addLine(to: topLeading)
        }
    }
}
struct SharpGradientBorder_Previews: PreviewProvider {
    static var previews: some View {
        SharpGradientBorder()
    }
}
