//
//  BezierView.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 10.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

typealias SideTuppleArr = [(point: CGPoint, pointArr: [Int])]

class BezierView: UIView {

    //MARK: Private Properties

    private var currentBezier: UIBezierPath!
    private var width = 0.0
    private var height = 0.0
    private let dotRadius: CGFloat = SupportFunc.returnRadius()
    private let lineWidth: CGFloat = SupportFunc.returnWidthLine()

    //MARK: Public Properties

    var vertexArrayCoord = [CGPoint]() {
        didSet {
            let changedIndexes = zip(vertexArrayCoord, oldValue).map{$0 != $1}.enumerated().filter{$1}.map{$0.0}

            for index in changedIndexes {
                let currentPoint = SupportFunc.returnNormPoint(point: vertexArrayCoord[index],
                                                               rad: dotRadius,
                                                               frame: frame)

                vertexArrayCoord[index] = currentPoint
            }
            sidePointArrayCoord = returnSideArray(pointArray: vertexArrayCoord)
            setNeedsDisplay()
        }
    }

    var sidePointArrayCoord = SideTuppleArr()

    //MARK: Lifecycle

    override func draw(_ rect: CGRect)  {
        currentBezier = UIBezierPath()

        setuplayout()
        drawFigure(from: vertexArrayCoord, in: rect)
        configureBezier()
        addDragDots(from: vertexArrayCoord)
    }

    //MARK: Private Methods

    private func setuplayout() {
        let correction = Double(dotRadius)

        width = Double(frame.width) - correction
        height = Double(frame.height) - correction

        if vertexArrayCoord.isEmpty {

            vertexArrayCoord = [CGPoint(x: correction, y: correction),
                                CGPoint(x: width, y: correction),
                                CGPoint(x: width, y: height),
                                CGPoint(x: correction, y: height)]
        }

        sidePointArrayCoord = returnSideArray(pointArray: vertexArrayCoord)
        addDragSideDots(from: sidePointArrayCoord)
    }

    private func drawFigure(from pointArray: [CGPoint], in rect: CGRect) {

        for point in pointArray {
            if point == pointArray.first {
                currentBezier.move(to: point)
            } else {
                currentBezier.addLine(to: point)
            }
        }
        currentBezier.close()
    }
    
    private func configureBezier() {
        currentBezier.lineWidth = lineWidth
        UIColor.blue.setStroke()
        currentBezier.stroke()
    }

    private func addDragDots(from pointArray: [CGPoint]) {
        for point in pointArray {
            drawDot(at: point)
        }
    }

    private func addDragSideDots(from pointArray: SideTuppleArr) {
        for point in pointArray {
            drawDot(at: point.0)
        }
    }
    private func drawDot(at center: CGPoint) {
        let path = UIBezierPath()
        path.addArc(withCenter: center,
                    radius: dotRadius,
                    startAngle: 0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: true)
        path.close()

        UIColor.blue.setFill()
        path.fill()
    }

    private func returnSideArray(pointArray: [CGPoint]) -> SideTuppleArr {
        if pointArray.count == 4 {
            var supportArray = [Int]()
            var newArray = SideTuppleArr()

            for i in 0..<pointArray.count {
                supportArray.append(i)
            }
            supportArray.append(0)

            for point in supportArray {
                let valuePoint = supportArray[point]
                let nextValuePoint = supportArray[point+1]
                let x = (pointArray[valuePoint].x + pointArray[nextValuePoint].x) / 2
                let y = (pointArray[valuePoint].y + pointArray[nextValuePoint].y) / 2
                
                newArray.append((CGPoint(x: x, y: y), [valuePoint, nextValuePoint]))
            }
            return newArray
        }
        return []
    }

}
