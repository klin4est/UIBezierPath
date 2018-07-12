//
//  BezierView.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 10.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

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

            setNeedsDisplay()
        }
    }

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
    }

    private func drawFigure(from vertexArray: [CGPoint], in rect: CGRect) {

        for point in vertexArray {
            if point == vertexArray.first {
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

}
