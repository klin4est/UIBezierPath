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

        let indentWidth = 20.0
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
        let currRad = SupportFunc.returnRadius()
        switch sender.state {
        case .began:

            let position = sender.location(in: senderView)
            let tuplePoint = returnIntersectPoint(currentPoint: position, in: senderView as! BezierView)

            if let catchPoint = tuplePoint.point,
                let indexPoint = tuplePoint.index {

                bezierPoint = catchPoint
                indexBezierPoint = indexPoint
            }

        case .changed:

            if let indexPoint = indexBezierPoint  {
                
                let bezierView = senderView as! BezierView
                let newPosition =  SupportFunc.returnNormPoint(point: sender.location(in: senderView),
                                                               rad: currRad,
                                                               frame: bezierView.frame)


                let convexFigure = SupportFunc.checkConvex(bezierView.vertexArrayCoord, index: indexPoint, point: newPosition)
                let pointOnLine = SupportFunc.checkPointOnPerimeter(bezierView.vertexArrayCoord, index: indexPoint, point: newPosition, frame: bezierView.frame)

                if convexFigure && pointOnLine {
                    
                    bezierView.vertexArrayCoord[indexPoint] = newPosition
                    bezierPoint = bezierView.vertexArrayCoord[indexPoint]
                }
            }

        case .ended:
            bezierPoint = nil
            indexBezierPoint = nil
        default:
            break
        }
    }

    private func returnIntersectPoint(currentPoint: CGPoint, in searchView: BezierView) -> (point: CGPoint?, index: Int?) {
        let arrayCGPoint = searchView.vertexArrayCoord
        //if we touch closer or equal 5 radii
        let maxDistance = 5 * SupportFunc.returnRadius()

        for (index, point) in arrayCGPoint.enumerated() {
            let currentDistance = SupportFunc.returnDistance(currentPoint, point)

            if currentDistance <= maxDistance {
                return (point , index)
            }
        }
        return (nil, nil)
    }

}

