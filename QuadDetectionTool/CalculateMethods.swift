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

    static func reduceValue(_ size: CGFloat, by indent: Double) -> Double {
        let answer = Double(size) - 2 * indent
        return answer
    }

    static func getDistance(segment: Segment) -> CGFloat {
        let xDist = segment.a.x - segment.b.x
        let yDist = segment.a.y - segment.b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

    static func getIntersection(_ segm1: Segment, with segm2: Segment) -> CGPoint {

        let distance = (segm1.b.x - segm1.a.x) * (segm2.b.y - segm2.a.y) - (segm1.b.y - segm1.a.y) * (segm2.b.x - segm2.a.x)
        if distance == 0 {
            //print("error, parallel segments")
            return CGPoint.zero
        }

        let u = ((segm2.a.x - segm1.a.x) * (segm2.b.y - segm2.a.y) - (segm2.a.y - segm1.a.y) * (segm2.b.x - segm2.a.x)) / distance
        let v = ((segm2.a.x - segm1.a.x) * (segm1.b.y - segm1.a.y) - (segm2.a.y - segm1.a.y) * (segm1.b.x - segm1.a.x)) / distance

        if (u < 0.0 || u > 1.0) {
            //print("error, intersection not inside segm1")
            return CGPoint.zero
        }
        if (v < 0.0 || v > 1.0) {
            //print("error, intersection not inside segm2")
            return CGPoint.zero
        }

        return CGPoint(x: segm1.a.x + u * (segm1.b.x - segm1.a.x), y: segm1.a.y + u * (segm1.b.y - segm1.a.y))
    }

    static func intersectByVector(with segment: Segment) -> CGPoint {
        let growth: CGFloat = 1000000 // for very big screen
        let deltaX = segment.b.x - segment.a.x
        let deltaY = segment.b.y - segment.a.y

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

    static func getStartIndex(for index: Int) -> Int {
        let array = [0,1,2,3,0,1]
        return array[index+2]
    }

    static func changeValue(vertexDragger newPosition: CGPoint, at index: Int, in view: BezierView) -> CGPoint? {
        var position: CGPoint? = nil
        var vertexes = view.getPolygon()

        vertexes[index] = newPosition
        let segment1: Segment = (a: vertexes[0], b: vertexes[2])
        let segment2: Segment = (a: vertexes[1], b: vertexes[3])
        let intersectPoint = CalculateMethods.getIntersection(segment1, with: segment2)
        let startIndex = CalculateMethods.getStartIndex(for: index)
        let startPosition = vertexes[startIndex]

        if intersectPoint != CGPoint.zero {
            view.changePolygonDraggers(to: newPosition, by: index)
            position = newPosition
        } else {
            //need vector
            let vectorPoint = CalculateMethods.intersectByVector(with: (startPosition, newPosition))
            if vectorPoint != CGPoint.zero {
                vertexes[index] = vectorPoint

                let segment1: Segment = (a: vertexes[0], b: vertexes[2])
                let segment2: Segment = (a: vertexes[1], b: vertexes[3])
                let intersectPoint = CalculateMethods.getIntersection(segment1, with: segment2)
                if intersectPoint != CGPoint.zero {
                    view.changePolygonDraggers(to: intersectPoint, by: index)
                    position = newPosition
                }
            }
        }
        return position
    }

    static func changeValue(sideDragger newPosition: CGPoint, at index: Int, in view: BezierView) -> CGPoint? {
        var copyArray = view.getPolygon()
        var copySideArray = view.getSidePolygon()
        let sideTupple = copySideArray[index]
        let vertexes = sideTupple.pointArr
        var position: CGPoint? = nil

        if index % 2 == 0 {
            for index in vertexes {
                let deltaY = newPosition.y - sideTupple.point.y
                let newPosition = copyArray[index].moveByXY(deltaY: deltaY)

                position = CalculateMethods.changeValue(vertexDragger: newPosition, at: index, in: view)
            }
        } else {
            for index in vertexes {
                let deltaX = newPosition.x - sideTupple.point.x
                let newPosition = copyArray[index].moveByXY(deltaX: deltaX)

                position = CalculateMethods.changeValue(vertexDragger: newPosition, at: index, in: view)
            }
        }
        return position
    }
}


