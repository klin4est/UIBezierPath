//
//  SupportFunc.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 09.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

class SupportFunc {

    //MARK: Common Methods

    static func returnReduced(_ sideSize: CGFloat, at indent: Double) -> Double {
        let answer = Double(sideSize) - 2 * indent
        return answer
    }

    static func returnWidthLine() -> CGFloat {
        return CGFloat(2.0)
    }

    static func returnRadius() -> CGFloat {
        return  CGFloat(6.0)
    }

    static func returnDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

    static func getIntersectionOfLines(line1: (a: CGPoint, b: CGPoint), line2: (a: CGPoint, b: CGPoint)) -> CGPoint {

        let distance = (line1.b.x - line1.a.x) * (line2.b.y - line2.a.y) - (line1.b.y - line1.a.y) * (line2.b.x - line2.a.x)
        if distance == 0 {
            //print("error, parallel lines")
            return CGPoint.zero
        }

        let u = ((line2.a.x - line1.a.x) * (line2.b.y - line2.a.y) - (line2.a.y - line1.a.y) * (line2.b.x - line2.a.x)) / distance
        let v = ((line2.a.x - line1.a.x) * (line1.b.y - line1.a.y) - (line2.a.y - line1.a.y) * (line1.b.x - line1.a.x)) / distance

        if (u < 0.0 || u > 1.0) {
            //print("error, intersection not inside line1")
            return CGPoint.zero
        }
        if (v < 0.0 || v > 1.0) {
            //print("error, intersection not inside line2")
            return CGPoint.zero
        }

        return CGPoint(x: line1.a.x + u * (line1.b.x - line1.a.x), y: line1.a.y + u * (line1.b.y - line1.a.y))
    }

    static func returnNormPoint(point: CGPoint, rad: CGFloat, frame: CGRect) -> CGPoint {
        var newPoint = point
        newPoint.x = min(max(newPoint.x, rad), CGFloat(frame.width - rad))
        newPoint.y = min(max(newPoint.y, rad), CGFloat(frame.height - rad))
        return newPoint
    }

    static func intersectByVector(startPoint: CGPoint, currentPoint: CGPoint) -> CGPoint {
        let growth: CGFloat = 1000000 // for very big screen
        let deltaX = currentPoint.x - startPoint.x
        let deltaY = currentPoint.y - startPoint.y

        let coeff: CGFloat = -1
        var intersectX: CGFloat = 0.0
        var intersectY: CGFloat = 0.0
        
        if deltaX > 0 && deltaY > 0 {
            intersectX = growth
            intersectY = intersectX * deltaY / deltaX
        } else if deltaX < 0 && deltaY < 0 {
            intersectX = growth * coeff
            intersectY = intersectX * deltaY / deltaX
        } else if deltaX > 0 && deltaY < 0 {
            intersectX = growth
            intersectY = intersectX * deltaY / deltaX
        } else if deltaX < 0 && deltaY > 0 {
            intersectX = growth * coeff
            intersectY = intersectX * deltaY / deltaX
        } else {
            return CGPoint.zero
        }

        return CGPoint(x: intersectX, y: intersectY)
    }

    static func returnStartPointIndex(index: Int) -> Int {
        let array = [0,1,2,3,0,1]
        return array[index+2]
    }

    static func returnMinMaxXY(polygon: [CGPoint]) -> (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        var minX: CGFloat = 0.0
        var maxX: CGFloat = 0.0
        var minY: CGFloat = 0.0
        var maxY: CGFloat = 0.0
        for point in polygon {
            if point == polygon.first {
                minX = point.x
                maxX = point.x
                minY = point.y
                maxY = point.y
            }
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }

        return (minX, maxX, minY, maxY)
    }
}
