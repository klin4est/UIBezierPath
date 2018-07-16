//
//  ViewController.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 09.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Private Properties

    var bezierViewOrigin: CGPoint!
    var bezierPoint: CGPoint?
    var indexBezierPoint: Int?
    var bezierSidePoint: CGPoint?
    var indexBezierSidePoint: Int?
    var arraySidePoint = [CGPoint]()

    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        var heightNavBar = 0.0
        if let height = navigationController?.navigationBar.bounds.height {
            heightNavBar = Double(height)
        }
        
        let currHeight = view.bounds.height
        let currWidth = view.bounds.width

        let indentWidth = 20.0 // magic indent
        let indentHeight = 2.5 * indentWidth + heightNavBar // magic indent
        let newWidth = SupportFunc.returnReduced(currWidth, at: indentWidth)
        let newHeight = SupportFunc.returnReduced(currHeight, at: indentHeight)

        let currFrame = CGRect(x: indentWidth,
                               y: indentHeight,
                               width: newWidth,
                               height: newHeight)

        let bezierView = BezierView(frame: currFrame)
        let photoView = returnSubViewWithPhoto(bezierView,
                                               width: newWidth,
                                               height: newHeight,
                                               indentWidth: indentWidth,
                                               indentHeight: indentHeight)
        bezierView.backgroundColor = .clear
        photoView.backgroundColor = .yellow
        bezierViewOrigin = bezierView.frame.origin
        view.addSubview(photoView)
        view.addSubview(bezierView)
        view.backgroundColor = .gray

        bezierView.contentMode = .redraw

        addPanGesture(view: bezierView)
    }

    private func returnSubViewWithPhoto(_ baseView : UIView,
                                        width : Double,
                                        height : Double,
                                        indentWidth : Double,
                                        indentHeight : Double) -> UIView {

        let offsetValue = Double(SupportFunc.returnRadius())
        let currFrame = CGRect(x: indentWidth + offsetValue,
                               y: indentHeight + offsetValue,
                               width: SupportFunc.returnReduced(CGFloat(width), at: offsetValue),
                               height: SupportFunc.returnReduced(CGFloat(height), at: offsetValue))

        let newView = UIView(frame: currFrame)

        return newView
    }

    private func addPanGesture(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector (ViewController.handlePan(sender:)))
        view.addGestureRecognizer(pan)
    }

    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let senderView = sender.view
        let bezierView = senderView as! BezierView

        switch sender.state {
        case .began:

            let position = sender.location(in: senderView)
            //catch drag dot
            let tuplePoint = returnIntersectPoint(currentPoint: position, in: bezierView.vertexArrayCoord)
            bezierPoint = nil
            indexBezierPoint = nil
            bezierSidePoint = nil
            indexBezierSidePoint = nil

            if let catchPoint = tuplePoint.point,
                let indexPoint = tuplePoint.index {

                bezierPoint = catchPoint
                indexBezierPoint = indexPoint
            }

            if bezierPoint == nil {
                arraySidePoint = []
                for side in bezierView.sidePointArrayCoord {
                    arraySidePoint += [side.0]
                }

                let tupleSidePoint = returnIntersectPoint(currentPoint: position, in: arraySidePoint)

                if let catchPoint = tupleSidePoint.point,
                    let indexPoint = tupleSidePoint.index {

                    bezierSidePoint = catchPoint
                    indexBezierSidePoint = indexPoint
                }

            }

        case .changed:
            let newPosition =  sender.location(in: senderView)

            //point alhorithm
            if let indexPoint = indexBezierPoint  {
                var copyArray = bezierView.vertexArrayCoord

                copyArray[indexPoint] = newPosition
                let intersectPoint = SupportFunc.getIntersectionOfLines(line1: (a: copyArray[0], b: copyArray[2]),
                                                                        line2: (a: copyArray[1], b: copyArray[3]))
                let startPointIndex = SupportFunc.returnStartPointIndex(index: indexPoint)
                let startPoint = copyArray[startPointIndex]

                if intersectPoint != CGPoint.zero {
                    bezierView.vertexArrayCoord[indexPoint] = newPosition
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

                            bezierView.vertexArrayCoord[indexPoint] = intersectPoint
                            bezierPoint = newPosition
                        }
                    }
                }
            }

            //side alhorithm
            if let indexPoint = indexBezierSidePoint {
                var copyArray = bezierView.vertexArrayCoord
                var copySideArray = bezierView.sidePointArrayCoord
                let sideTupple = copySideArray[indexPoint]
                let arrVertexPoint = sideTupple.pointArr
                if indexPoint % 2 == 0 {

                    for index in arrVertexPoint {

                        let deltaY = newPosition.y - sideTupple.point.y
                        print("newPosition \(newPosition) ")
                        print("deltaY \(deltaY)")
                        let currentX = copyArray[index].x
                        let currentY = copyArray[index].y + deltaY
                        bezierView.vertexArrayCoord[index] = CGPoint(x: currentX, y: currentY)
                    }
                } else {
                    for index in arrVertexPoint {
                        let deltaX = newPosition.x - sideTupple.point.x
                        print("deltaX \(deltaX)")
                        let currentX = copyArray[index].x + deltaX
                        let currentY = copyArray[index].y
                        bezierView.vertexArrayCoord[index] = CGPoint(x: currentX, y: currentY)
                    }
                }
            }

        case .ended:
            bezierPoint = nil
            indexBezierPoint = nil
        default:
            break
        }
    }

    private func returnIntersectPoint(currentPoint: CGPoint, in arrayCGPoint: [CGPoint]) -> (point: CGPoint?, index: Int?) {
        //if we touch closer or equal 3 radii
        let maxDistance = 3 * SupportFunc.returnRadius()

        for (index, point) in arrayCGPoint.enumerated() {
            let currentDistance = SupportFunc.returnDistance(currentPoint, point)

            if currentDistance <= maxDistance {
                return (point , index)
            }
        }
        return (nil, nil)
    }

}

