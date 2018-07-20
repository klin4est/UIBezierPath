//
//  SupportFunc.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 09.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

class SupportFunc {

    //MARK: Initializer
    
    private init() {}

    //MARK: Common Methods

    static func reduceValue(_ sideSize: CGFloat, at indent: Double) -> Double {
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

    static func movePoint(at bezierView: BezierView, to newPosition: CGPoint, indexPoint: Int) -> CGPoint? {
        var bezierPoint: CGPoint? = nil
        var copyArray = bezierView.returnPolygon()

        copyArray[indexPoint] = newPosition
        let intersectPoint = SupportFunc.getIntersectionOfLines(line1: (a: copyArray[0], b: copyArray[2]),
                                                                line2: (a: copyArray[1], b: copyArray[3]))
        let startPointIndex = SupportFunc.returnStartPointIndex(index: indexPoint)
        let startPoint = copyArray[startPointIndex]

        if intersectPoint != CGPoint.zero {
            bezierView.changePointInPolygon(index: indexPoint, point: newPosition)
            bezierPoint = newPosition
        } else {
            //need vector
            let vectorPoint = SupportFunc.intersectByVector(startPoint: startPoint,
                                                            currentPoint: newPosition)
            if vectorPoint != CGPoint.zero {
                copyArray[indexPoint] = vectorPoint

                let intersectPoint = SupportFunc.getIntersectionOfLines(line1: (a: copyArray[0], b: copyArray[2]),
                                                                        line2: (a: copyArray[1], b: copyArray[3]))
                if intersectPoint != CGPoint.zero {
                    bezierView.changePointInPolygon(index: indexPoint, point: intersectPoint)
                    bezierPoint = newPosition
                }
            }
        }
        return bezierPoint
    }

    static func moveSide(at bezierView: BezierView, to newPosition: CGPoint, indexPoint: Int) -> CGPoint? {
        var copyArray = bezierView.returnPolygon()
        var copySideArray = bezierView.sidePointArrayCoord
        let sideTupple = copySideArray[indexPoint]
        let arrVertexPoint = sideTupple.pointArr
        var currentPoint: CGPoint? = nil
        var currentX: CGFloat = 0.0
        var currentY: CGFloat = 0.0

        if indexPoint % 2 == 0 {
            for index in arrVertexPoint {
                let deltaY = newPosition.y - sideTupple.point.y
                currentX = copyArray[index].x
                currentY = copyArray[index].y + deltaY

                let newPosition = CGPoint(x: currentX, y: currentY)

                currentPoint = SupportFunc.movePoint(at: bezierView, to: newPosition, indexPoint: index)
            }
        } else {
            for index in arrVertexPoint {
                let deltaX = newPosition.x - sideTupple.point.x
                currentX = copyArray[index].x + deltaX
                currentY = copyArray[index].y

                let newPosition = CGPoint(x: currentX, y: currentY)

                currentPoint = SupportFunc.movePoint(at: bezierView, to: newPosition, indexPoint: index)
            }
        }
        return currentPoint
    }

    static func makeFrame(frame: CGRect ,indentWidth: Double, indentHeight: Double) -> CGRect {
        let newWidth = SupportFunc.reduceValue(frame.width, at: indentWidth)
        let newHeight = SupportFunc.reduceValue(frame.height, at: indentHeight)

        return CGRect(x: indentWidth, y: indentHeight, width: newWidth, height: newHeight)
    }

    static func makeBezierView(frame: CGRect) -> BezierView {
        let bezierView = BezierView(frame: frame)
        bezierView.backgroundColor = .clear
        bezierView.contentMode = .redraw

        return bezierView
    }

    static func makeView(frame: CGRect, indentWidth : Double, indentHeight : Double) -> UIView {

        let offsetValue = Double(SupportFunc.returnRadius())
        let newWidth = SupportFunc.reduceValue(frame.width, at: offsetValue)
        let newHeight = SupportFunc.reduceValue(frame.height, at: offsetValue)

        let newFrame = CGRect(x: indentWidth + offsetValue,
                               y: indentHeight + offsetValue,
                               width: newWidth,
                               height: newHeight)
        let newView = UIView(frame: newFrame)
        newView.backgroundColor = .yellow

        return newView
    }
}
