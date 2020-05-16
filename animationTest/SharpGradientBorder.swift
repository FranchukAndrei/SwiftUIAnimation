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
    init(start: Color = .red,
        end: Color = .blue,
        bottomRadius: CGFloat = 30,
        topRadius: CGFloat = 100,
        gradientLength: CGFloat = 60){
        self.start = start
        self.end = end
        self.bottomRadius = bottomRadius
        self.topRadius = topRadius
        self.gradientLength = gradientLength
    }
    var body: some View {
        ZStack{
            HStack(spacing: 0){
                Rectangle()
                    .fill(start)
                Rectangle()
                    .fill(end)
            }
            GradientView(start: start, end: end, bottomRadius: bottomRadius, topRadius: topRadius, gradientLength: gradientLength)
                .frame(width: bottomRadius + topRadius + gradientLength)
                .clipped()
            
        }.background(end)
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
            }
        }
    }
}
struct SharpGradientBorder_Previews: PreviewProvider {
    static var previews: some View {
        SharpGradientBorder()
    }
}
