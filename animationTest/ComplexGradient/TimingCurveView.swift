//
//  TimingCurve.swift
//  animationTest
//
//  Created by Франчук Андрей on 26.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

class TimingCurve{
    class StoredCurveParts{
        var trimmedCurve: Path
        var startPoint: CGPoint
        var endPoint: CGPoint
        var startPart: CGFloat
        var endPart: CGFloat
        init(trimmedCurve: Path, startPoint: CGPoint, endPoint: CGPoint, startPart: CGFloat, endPart: CGFloat){
            self.trimmedCurve = trimmedCurve
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.startPart = startPart
            self.endPart = endPart
        }
    }
    static var superEaseInPath: Path = Path(){path in
    path.move(to: CGPoint(x: 0, y: 0))
    path.addCurve(to: CGPoint(x: 1, y: 1),
                  control1: TimingCurve.control.point1,
                  control2: TimingCurve.control.point2
        )}
    static var storedCurveParts: [StoredCurveParts] = [StoredCurveParts(
        trimmedCurve: TimingCurve.superEaseInPath,
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 1, y: 1),
        startPart: 0,
        endPart: 1)]
    let duration: CGFloat
    let curve: Path
    init(duration: CGFloat){
        self.duration = duration
        self.curve = TimingCurve.superEaseInPath
    }
    
    //gets actual timing of given value according to trimming curve
    //position must by in (0...1) interval
//    func getActual(of position: CGFloat) -> CGFloat{
//        let correctPosition = max(min(position, 1), 0) / duration
//        if correctPosition < 0.0000001{
//            let reversedCurve = Path(UIBezierPath(cgPath: self.trimmingCurve.cgPath).reversing().cgPath)
//            //trim to start point is impossible, so reverce the curve and get last point
//            guard let point = reversedCurve.currentPoint else{fatalError("cant get current timing curve start point")}
//            return point.y
//        }
//        guard let point = trimmingCurve.trimmedPath(from: 0, to: correctPosition).currentPoint else{fatalError("cant get current timing curve point at \(position)")}
//        return point.y * self.duration
//    }
    
    func getY(onX: CGFloat) -> CGFloat{
        let x = onX / duration
        guard var currentInd = TimingCurve.storedCurveParts.firstIndex(where: {$0.startPoint.x <= x && x <= $0.endPoint.x}) else{fatalError("curve doesnt contain point with such x: \(x)")}
        var currentPart = TimingCurve.storedCurveParts[currentInd]
        var delta = min(currentPart.endPoint.x - x, x - currentPart.startPoint.x)
        while delta > 0.001{
            let starthalf = currentPart.trimmedCurve.trimmedPath(from: 0, to: 0.5)
            guard let middlePoint = starthalf.currentPoint else{fatalError("curve too small")}
            let middlePosition = currentPart.startPart + (currentPart.endPart - currentPart.startPart) / 2
            let startPart = StoredCurveParts(trimmedCurve: starthalf,
                                             startPoint: currentPart.startPoint,
                                             endPoint: middlePoint,
                                             startPart: currentPart.startPart,
                                             endPart: middlePosition)
            let endHalf = currentPart.trimmedCurve.trimmedPath(from: 0.5, to: 1)
            let endPart = StoredCurveParts(trimmedCurve: endHalf,
                                             startPoint: middlePoint,
                                             endPoint: currentPart.endPoint,
                                             startPart: middlePosition,
                                             endPart: currentPart.endPart)
            TimingCurve.storedCurveParts.remove(at: currentInd)
            if middlePoint.x > x{
                currentPart = startPart
                TimingCurve.storedCurveParts.append(endPart)
            }else{
                currentPart = endPart
                TimingCurve.storedCurveParts.append(startPart)
            }
            TimingCurve.storedCurveParts.append(currentPart)
            let ind = TimingCurve.storedCurveParts.index(before: TimingCurve.storedCurveParts.endIndex)
            guard TimingCurve.storedCurveParts[ind].startPoint == currentPart.startPoint && TimingCurve.storedCurveParts[ind].endPoint == currentPart.endPoint else{fatalError("cant get just added element")}
            currentInd = ind
            delta = currentPart.endPoint.x - currentPart.startPoint.x
        }
        let xFromStart = x - currentPart.startPoint.x
        let xToEnd = currentPart.endPoint.x - x
        let yInterval = currentPart.endPoint.y - currentPart.startPoint.y
        let y = currentPart.startPoint.y + yInterval * (xFromStart / (xFromStart + xToEnd))
 //       print("x: \(x); y: \(y)")
        return y
        //return (currentPart.startPoint.y + currentPart.endPoint.y) / 2
    }
    static var control: (point1: CGPoint, point2: CGPoint){
        let point1 = CGPoint(x: 0.2, y: 0)//increase x for slower waves moving at the start
        let point2 = CGPoint(x: 1, y: 0.7)//decrease y for faster waves moving closer to end
        return (point1: point1, point2: point2)
    }

    static func superEaseIn(duration: CGFloat = 1) -> TimingCurve{

        let curve = TimingCurve(duration: duration)
        return curve
    }
}
struct TimingCurveView: View{
    let curve = TimingCurve.superEaseIn(duration: 1)
    let scale: CGFloat = 300
    let testPoints: [CGFloat] = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 1]
    var body: some View{
        Rectangle()
            .fill(Color.gray)
            .frame(width: 1, height: 1)
            .overlay(
                curve.curve
                    .stroke(Color.black, lineWidth: 0.01)
            )
            .scaleEffect(self.scale)
//            .overlay(
//                ZStack{
//                    ForEach(testPoints, id: \.self){point in
//                        Circle()
//                            .fill(Color.red)
//                            .frame(width: 20, height: 20)
//                            .offset(x: (point  - 0.5) * self.scale,
//                                    y: (self.curve.getActual(of: point) - 0.5) * self.scale)
//                    }
//                }
//            )
            .overlay(
                ZStack{
                    ForEach(testPoints, id: \.self){point in
                        Circle()
                            .fill(Color.green)
                            .frame(width: 20, height: 20)
                            .offset(x: (point  - 0.5) * self.scale,
                                    y: (self.curve.getY(onX: point) - 0.5) * self.scale)
                    }
                }
            )
            .rotation3DEffect(Angle(degrees:180), axis: (x: 1, y: 0, z: 0))
        .frame(width: scale, height: scale)
    }
}

struct TimingCurveView_Previews: PreviewProvider {
    static var previews: some View {
        TimingCurveView()
    }
}
