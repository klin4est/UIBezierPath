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

    static func checkConvex(_ vertexArray: [CGPoint], index: Int, point: CGPoint) -> Bool {
        let path = UIBezierPath()
        var currArray = vertexArray
        currArray.remove(at: index)

        for i in currArray {
            if i == currArray.first {
                path.move(to: i)
            } else {
                path.addLine(to: i)
            }
        }
        path.close()

        return !path.contains(point)
    }
    static func checkPointOnPerimeter(_ vertexArray: [CGPoint], index: Int, point: CGPoint, frame: CGRect) -> Bool {

        let newArr = vertexArray + vertexArray
        var answer = true

        for i in 1...3 {
            let path = UIBezierPath()
            path.move(to: newArr[index + i])
            path.addLine(to: newArr[index + i + 1])
            path.close()

            if path.contains(point) {
                answer = false
            }
        }

        return answer
    }

    static func returnNormPoint(point: CGPoint, rad: CGFloat, frame: CGRect) -> CGPoint {
        var newPoint = point
        newPoint.x = min(max(newPoint.x, rad), CGFloat(frame.width - rad))
        newPoint.y = min(max(newPoint.y, rad), CGFloat(frame.height - rad))
        return newPoint
    }
}
