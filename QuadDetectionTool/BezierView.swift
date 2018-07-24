//
//  BezierView.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 10.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

typealias SideTuppleArr = [(point: CGPoint, pointArr: [Int])]

final class BezierView: UIView {

    //MARK: Private Properties

    private var path: UIBezierPath!
    private var width = 0.0
    private var height = 0.0
    private let dotRadius = CGFloat(Constants.dotRadius)
    private let lineWidth = CGFloat(Constants.lineWidth)
    private var sideDraggers = SideTuppleArr()
    private var draggers = [CGPoint]() {
        didSet {
            let changedIndexes = zip(draggers, oldValue).map{$0 != $1}.enumerated().filter{$1}.map{$0.0}

            for index in changedIndexes {
                let position = draggers[index].getCorrectPosition(in: frame)

                changeVertexInPolygon(index: index, vertex: position)
            }
            self.sideDraggers = getSideArray(pointArray: draggers)
            setNeedsDisplay()
        }
    }

    //MARK: Lifecycle

    override func draw(_ rect: CGRect)  {
        self.path = UIBezierPath()

        setuplayout()
        drawPath(with: self.draggers)
        addDragDots(from: self.draggers)
        addDragSideDots(from: self.sideDraggers)
    }

    //MARK: Public Methods

    func changeVertexInPolygon(index: Int, vertex: CGPoint) {
        self.draggers[index] = vertex
    }

    func getPolygon() -> [CGPoint] {
        return self.draggers
    }

    func getSidePolygon() -> SideTuppleArr {
        return self.sideDraggers
    }
    //MARK: Private Methods

    private func setuplayout() {
        let correction = Constants.dotRadius

        self.width = Double(frame.width) - correction
        self.height = Double(frame.height) - correction

        if self.draggers.isEmpty {

            self.draggers = [CGPoint(x: correction, y: correction),
                                CGPoint(x: self.width, y: correction),
                                CGPoint(x: self.width, y: self.height),
                                CGPoint(x: correction, y: self.height)]
        }

        self.sideDraggers = getSideArray(pointArray: self.draggers)

    }

    private func drawPath(with vertexes: [CGPoint]) {
        if vertexes.count > 0 {
            self.path.move(to: vertexes.first!)
            vertexes.forEach{self.path.addLine(to: $0)}
            self.path.close()
            self.path.lineWidth = self.lineWidth
            UIColor.blue.setStroke()
            self.path.stroke()
        }
    }


    private func addDragDots(from vertexes: [CGPoint]) {
        vertexes.forEach{drawDot(at: $0)}
    }

    private func addDragSideDots(from sideDots: SideTuppleArr) {
        sideDots.forEach{drawDot(at: $0.point)}
    }
    private func drawDot(at center: CGPoint) {
        let path = UIBezierPath()
        path.addArc(withCenter: center,
                    radius: self.dotRadius,
                    startAngle: 0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: true)
        path.close()

        UIColor.blue.setFill()
        path.fill()
    }

    private func getSideArray(pointArray: [CGPoint]) -> SideTuppleArr {
        if pointArray.count == 4 {
            var supportArray = [Int]()
            var sidesWithDotIndex = SideTuppleArr()

            for i in 0..<pointArray.count {
                supportArray.append(i)
            }
            supportArray.append(0)

            for point in supportArray {

                let startIndex = supportArray[point]
                let nextIndex = supportArray[point+1]

                let position = pointArray[startIndex]
                let nextPosition = pointArray[nextIndex]
                let sideDragger = position.getMiddle(to: nextPosition)
                sidesWithDotIndex.append((sideDragger, [startIndex, nextIndex]))
            }
            return sidesWithDotIndex
        }
        return []
    }

}
