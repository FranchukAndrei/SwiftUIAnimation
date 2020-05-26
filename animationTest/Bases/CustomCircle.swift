//
//  CustomCircle.swift
//  animationTest
//
//  Created by Франчук Андрей on 15.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct CustomCircle: Shape, Animatable{
    var animatableData: CGFloat{
         get{
             radius
         }
         set{
            print("new radius is \(newValue)")
            radius = newValue
         }
     }
    var radius: CGFloat
    public func path(in rect: CGRect) -> Path{
        //let radius = min(rect.width, rect.height) / 2
        //да, можно конечно не передавать радиус, а вычислять его непосредственно в функции, это не сложно, и на самом деле это правильно. В этом случае анимация будет работать. Но в целях обучения, представим что у нас просто некая абстрактная фигура, зависящая от внешнего параметра
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        return Path(){path in
            if rect.width > rect.height{
                path.move(to: CGPoint(x: center.x, y: 0))
                let startAngle = Angle(degrees: 270)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle:  startAngle + Angle(degrees: 360), clockwise: false)
            }else{
                path.move(to: CGPoint(x: 0, y: center.y))
                let startAngle = Angle(degrees: 0)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle:  startAngle + Angle(degrees: 360), clockwise: false)
            }
            path.closeSubpath()
        }
    }
}
struct CircleView: View{
    var radius: CGFloat
    var body: some View{
        Circle()
            .fill(Color.green)
            .frame(height: self.radius * 2)
            .overlay(
                Text("Habra")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                )

    }
}
struct CustomCircleView: View{
    var radius: CGFloat
    var body: some View{
        CustomCircle(radius: radius)
//        CustomCircle()
            .fill(Color.gray)
            //.frame(height: self.radius * 2)
            .overlay(
                Text("Habr")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                )
    }
}

struct CustomCircleTestView: View {
    @State var radius: CGFloat = 50
    var body: some View {
        VStack{
            HStack{
                CircleView(radius: radius)
                    .frame(height: 200)
                CustomCircleView(radius: radius)
                    .frame(height: 200)
            }
            Slider(value: self.$radius, in: 42...100)
            Button(action: {
                withAnimation(.linear(duration: 1)){
                    self.radius = 50
                }
            }){
                Text("set default radius")
            }
        }
    }
}

struct CustomCircle_Previews: PreviewProvider {
    static var previews: some View {
        CustomCircleTestView()
    }
}
