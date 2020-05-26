//
//  TimingCurve.swift
//  animationTest
//
//  Created by Франчук Андрей on 26.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

extension Path {
    func getPointWithGiven(y: CGFloat, startWith: CGPoint? = nil) -> CGPoint{
        var startPoint = CGPoint.zero
        if let s = startWith{
            startPoint = s
        }else{
            let revercedPAth = Path(UIBezierPath(cgPath: self.cgPath).reversing().cgPath)
            guard let s = revercedPAth.currentPoint else {fatalError("cant get start point of the curve")}
            startPoint = s
        }
        let firstHalf = self.trimmedPath(from: 0, to: 0.51)
        guard let middlePoint = firstHalf.currentPoint else{fatalError("cant middle start point")}
        let secondHalf = self.trimmedPath(from: 0.49, to: 1)
        guard let endPoint = secondHalf.currentPoint else{fatalError("cant get end point")}
        if startPoint.y <= y && y < middlePoint.y || startPoint.y > y && y >= middlePoint.y{
            let delta = startPoint.y - middlePoint.y
            if max(delta, -delta) < 1 {
                //found one
                let startDelta = startPoint.y - y
                let endDelta = middlePoint.y - y
                if max(startDelta, -startDelta) > max(endDelta, -endDelta){
                    return middlePoint
                }else{
                    return startPoint
                }
            }else{
                return firstHalf.getPointWithGiven(y: y, startWith: startPoint)
            }
        }else if   middlePoint.y <= y && y <= endPoint.y || middlePoint.y >= y && y >= endPoint.y{
            let delta = middlePoint.y - endPoint.y
            if max(delta, -delta) < 1 {
                //found one
                let startDelta = middlePoint.y - y
                let endDelta = endPoint.y - y
                if max(startDelta, -startDelta) > max(endDelta, -endDelta){
                    return endPoint
                }else{
                    return middlePoint
                }
            }else{
                return secondHalf.getPointWithGiven(y: y, startWith: middlePoint)
            }
        }else{
            fatalError("curve  (from \(startPoint.y) to \(endPoint.y) doesnt contains point with given y - \(y)")
        }
    }
}

struct TimingCurve{
    let trimmingCurve: Path
    let duration: CGFloat
    
    init(from start: CGPoint, to end: CGPoint, cp1: CGPoint, cp2: CGPoint){
        self.duration = end.x - start.x
        self.trimmingCurve = Path(){path in
            path.move(to: start)
            path.addCurve(to: end, control1: cp1, control2: cp2)
        }
    }
    //gets actual timing of given value according to trimming curve
    //position must by in (0...1) interval
    func getActual(of position: CGFloat) -> CGFloat{
        let correctPosition = max(min(position, 1), 0)// -reserve <= correctPosition <= duration+reserve
        
        if correctPosition < 0.0000001{
            let reversedCurve = Path(UIBezierPath(cgPath: self.trimmingCurve.cgPath).reversing().cgPath)
            //trim to start point is impossible, so reverce the curve and get last point
            guard let point = reversedCurve.currentPoint else{fatalError("cant get current timing curve start point")}
            return point.y
        }
        guard let point = trimmingCurve.trimmedPath(from: 0, to: correctPosition).currentPoint else{fatalError("cant get current timing curve point at \(position)")}
        return point.y * self.duration
    }
    static func superEaseOut(duration: CGFloat = 1) -> TimingCurve{
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: duration, y: duration)
        let control = TimingCurve.getControlPoints()
        return TimingCurve(from: startPoint, to: endPoint, cp1: control.point1, cp2: control.point2)
    }
    static func getControlPoints() -> (point1: CGPoint, point2: CGPoint){
        let cp1 = CGPoint(x: 1, y: 0)//increase x for slower waves moving at the start
        let cp2 = CGPoint(x: 1, y: 0)//decrease y for faster waves moving closer to end
        return (point1: cp1, point2: cp2)
    }
}
struct TimingCurveView: View{
    let curve = TimingCurve.superEaseOut()
    var body: some View{
        Rectangle()
            .fill(Color.gray)
            .frame(width: 1, height: 1)
            .overlay(
                curve.trimmingCurve
                    .stroke(Color.black, lineWidth: 0.004)
            )
        
            .scaleEffect(300)
    }
}

struct TimingCurveView_Previews: PreviewProvider {
    static var previews: some View {
        TimingCurveView()
    }
}
