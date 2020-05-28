//
//  customState.swift
//  animationTest
//
//  Created by Франчук Андрей on 08.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI


struct ContentView: View{
    @State var position: CGFloat = 0
    var body: some View{
//        RainbowBarExampleView()
//        SimpleBorderMove()
//         TransitionTestView()
        TransitionRainbowView()
//        SharpGradientBorder()
        //     CustomCircleTestView()
      //  TestRainbowView()
//         AdvancedTimingRainbow()
       // ZIndexTestView()
       // AnimationStopping()
        //FullSwiftUIRainbow()
//               TransitionView()
 //       TimingCurveView()
  //      TransitionWithInfiniteAnimation()
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
