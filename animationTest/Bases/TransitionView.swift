//
//  Transition.swift
//  animationTest
//
//  Created by Франчук Андрей on 25.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static func spinIn(anchor: UnitPoint) -> AnyTransition {
        .modifier(
            active: SpinTransitionModifier(angle: -90, anchor: anchor),
            identity: SpinTransitionModifier(angle: 0, anchor: anchor))
    }
    static func spinOut(anchor: UnitPoint) -> AnyTransition {
        .modifier(
            active: SpinTransitionModifier(angle: 90, anchor: anchor),
            identity: SpinTransitionModifier(angle: 0, anchor: anchor))
    }

}


struct SpinTransitionModifier: ViewModifier {
    let angle: Double
    let anchor: UnitPoint
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: angle), anchor: anchor)
            .clipped()
    }
}

struct TransitionView: View {
    let views: [AnyView] = [AnyView(CustomCircleTestView()), AnyView(SimpleBorderMove())]
    @State var currentViewInd = 0
    var body: some View {
        VStack{
            Spacer()
            ZStack{
                ForEach(views.indices, id: \.self){(ind: Int) in
                    Group{
                        if ind == self.currentViewInd{
 //                           self.views[ind]
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 100, height: 100)
                                .border(Color.black, width: 2)
                                .overlay(Text("\(ind + 1)"))
                         //       .transition(.scale)
//                               .transition(.asymmetric(
//                                    insertion: .scale(scale: 0.1, anchor: .leading),
//                                    removal: .move(edge: .trailing)))
                              .transition(.asymmetric(
                                  insertion: .spinIn(anchor: .bottomTrailing),
                                  removal: .spinOut(anchor: .bottomTrailing)))
                        }
                    }
                }
            }
            HStack{
                ForEach(views.indices, id: \.self){(ind: Int) in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ind == self.currentViewInd ? Color.green : Color.gray)
                        .overlay(
                            Text("\(ind + Int(1))"))
                        .onTapGesture{
                            withAnimation(.linear(duration: 1)){
                                self.currentViewInd = ind
                            }
                    }
                }
            }
                .frame(height: 50)
            Spacer()
        }
    }
}

struct TransitionView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionView()
    }
}
