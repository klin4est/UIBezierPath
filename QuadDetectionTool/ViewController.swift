//
//  ViewController.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 09.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    //MARK: Private Properties

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
        let currentView = self.view!
        var heightNavBar = 0.0
        if let height = navigationController?.navigationBar.bounds.height {
            heightNavBar = Double(height)
        }
        let indentWidth = 20.0 // magic indent
        let indentHeight = 2.5 * indentWidth + heightNavBar // magic indent

        let currentFrame = currentView.bounds
        let secondFrame = SupportFunc.makeFrame(frame: currentFrame, indentWidth: indentWidth, indentHeight: indentHeight)
        let bezierView = SupportFunc.makeBezierView(frame: secondFrame)
        let photoView = SupportFunc.makeView(frame: secondFrame, indentWidth: indentWidth, indentHeight: indentHeight)

        currentView.addSubview(photoView)
        currentView.addSubview(bezierView)
        currentView.backgroundColor = .gray

        addPanGesture(view: bezierView)
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
            setStartValueForPoints()

            //catch drag dot
            catchDragDot(position: position, bezierView: bezierView)

        case .changed:
            let newPosition =  sender.location(in: senderView)

            //point alhorithm
            if let indexPoint = indexBezierPoint  {
                self.bezierPoint = SupportFunc.movePoint(at: bezierView, to: newPosition, indexPoint: indexPoint)
            }

            //side alhorithm
            if let indexPoint = indexBezierSidePoint {
                self.bezierPoint = SupportFunc.moveSide(at: bezierView, to: newPosition, indexPoint: indexPoint)
            }

        case .ended:
            setStartValueForPoints()
        default:
            break
        }
    }

    private func setStartValueForPoints() {
        self.bezierPoint = nil
        self.indexBezierPoint = nil
        self.bezierSidePoint = nil
        self.indexBezierSidePoint = nil
    }

    private func catchDragDot(position: CGPoint, bezierView: BezierView) {
        let tuplePoint = returnIntersectPoint(currentPoint: position, in: bezierView.returnPolygon())

        if let catchPoint = tuplePoint.point,
            let indexPoint = tuplePoint.index {

            self.bezierPoint = catchPoint
            self.indexBezierPoint = indexPoint
        }

        if self.bezierPoint == nil {
            self.arraySidePoint = []
            for side in bezierView.sidePointArrayCoord {
                self.arraySidePoint += [side.0]
            }

            let tupleSidePoint = returnIntersectPoint(currentPoint: position, in: arraySidePoint)

            if let catchPoint = tupleSidePoint.point,
                let indexPoint = tupleSidePoint.index {

                self.bezierSidePoint = catchPoint
                self.indexBezierSidePoint = indexPoint
            }

        }
    }

    private func returnIntersectPoint(currentPoint: CGPoint, in arrayCGPoint: [CGPoint]) -> (point: CGPoint?, index: Int?) {
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

