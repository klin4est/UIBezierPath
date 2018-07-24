//
//  CalculateMethods.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 09.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

typealias Segment = (a: CGPoint, b:CGPoint)

class CalculateMethods {

    //MARK: Common Methods

    static func reduceValue(_ size: CGFloat, at indent: Double) -> Double {
        let answer = Double(size) - 2 * indent
        return answer
    }

    static func getDistance(line: Segment) -> CGFloat {
        let xDist = line.a.x - line.b.x
        let yDist = line.a.y - line.b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

    static func getIntersectionOfLines(line1: Segment, line2: Segment) -> CGPoint {

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

    static func intersectByVector(line: Segment) -> CGPoint {
        let growth: CGFloat = 1000000 // for very big screen
        let deltaX = line.b.x - line.a.x
        let deltaY = line.b.y - line.a.y

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

    static func getStartIndex(index: Int) -> Int {
        let array = [0,1,2,3,0,1]
        return array[index+2]
    }

    static func movePoint(at bezierView: BezierView, to newPosition: CGPoint, indexPoint: Int) -> CGPoint? {
        var bezierPoint: CGPoint? = nil
        var copyArray = bezierView.getPolygon()

        copyArray[indexPoint] = newPosition
        let intersectPoint = CalculateMethods.getIntersectionOfLines(line1: (a: copyArray[0], b: copyArray[2]),
                                                                line2: (a: copyArray[1], b: copyArray[3]))
        let startPointIndex = CalculateMethods.getStartIndex(index: indexPoint)
        let startPoint = copyArray[startPointIndex]

        if intersectPoint != CGPoint.zero {
            bezierView.changeVertexInPolygon(index: indexPoint, vertex: newPosition)
            bezierPoint = newPosition
        } else {
            //need vector
            let vectorPoint = CalculateMethods.intersectByVector(line: (startPoint, newPosition))
            if vectorPoint != CGPoint.zero {
                copyArray[indexPoint] = vectorPoint

                let intersectPoint = CalculateMethods.getIntersectionOfLines(line1: (a: copyArray[0], b: copyArray[2]),
                                                                        line2: (a: copyArray[1], b: copyArray[3]))
                if intersectPoint != CGPoint.zero {
                    bezierView.changeVertexInPolygon(index: indexPoint, vertex: intersectPoint)
                    bezierPoint = newPosition
                }
            }
        }
        return bezierPoint
    }

    static func moveSide(at bezierView: BezierView, to newPosition: CGPoint, indexPoint: Int) -> CGPoint? {
        var copyArray = bezierView.getPolygon()
        var copySideArray = bezierView.getSidePolygon()
        let sideTupple = copySideArray[indexPoint]
        let arrVertexPoint = sideTupple.pointArr
        var position: CGPoint? = nil

        if indexPoint % 2 == 0 {
            for index in arrVertexPoint {
                let deltaY = newPosition.y - sideTupple.point.y
                let newPosition = copyArray[index].moveByXY(deltaY: deltaY)

                position = CalculateMethods.movePoint(at: bezierView, to: newPosition, indexPoint: index)
            }
        } else {
            for index in arrVertexPoint {
                let deltaX = newPosition.x - sideTupple.point.x
                let newPosition = copyArray[index].moveByXY(deltaX: deltaX)

                position = CalculateMethods.movePoint(at: bezierView, to: newPosition, indexPoint: index)
            }
        }
        return position
    }



    static func makeBezierView(frame: CGRect) -> BezierView {
        let bezierView = BezierView(frame: frame)
        bezierView.backgroundColor = .clear
        bezierView.contentMode = .redraw

        return bezierView
    }

    static func makeView(frame: CGRect, indentWidth : Double, indentHeight : Double) -> UIView {

        let newFrame = frame.reduce(indentWidth: indentWidth, indentHeight: indentHeight, offsetValue: Constants.dotRadius)
        
        let newView = UIView(frame: newFrame)
        newView.backgroundColor = .yellow

        return newView
    }
}


