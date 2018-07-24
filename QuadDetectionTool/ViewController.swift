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
        guard let currentView = self.view else { return }

        let indentWidth = 20.0 // magic indent
        let indentHeight = 20.0 // magic indent

        let currentFrame = currentView.bounds
        let secondFrame = currentFrame.reduce(indentWidth: indentWidth, indentHeight: indentHeight)
        let bezierView = CalculateMethods.makeBezierView(frame: secondFrame)
        let photoView = CalculateMethods.makeView(frame: secondFrame, indentWidth: indentWidth, indentHeight: indentHeight)

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
        guard let bezierView = sender.view as? BezierView else { return }

        switch sender.state {
        case .began:

            let position = sender.location(in: bezierView)
            setStartValueForPoints()

            //catch drag dot
            catchDragDot(position: position, on: bezierView)

        case .changed:
            let newPosition =  sender.location(in: bezierView)

            //point alhorithm
            if let indexPoint = indexBezierPoint  {
                self.bezierPoint = CalculateMethods.movePoint(at: bezierView, to: newPosition, indexPoint: indexPoint)
            }

            //side alhorithm
            if let indexPoint = indexBezierSidePoint {
                self.bezierPoint = CalculateMethods.moveSide(at: bezierView, to: newPosition, indexPoint: indexPoint)
            }

        default:
            setStartValueForPoints()
        }
    }

    private func setStartValueForPoints() {
        self.bezierPoint = nil
        self.indexBezierPoint = nil
        self.bezierSidePoint = nil
        self.indexBezierSidePoint = nil
    }

    private func catchDragDot(position: CGPoint, on view: BezierView) {
        let tuplePoint = getIntersect(currentPoint: position, in: view.getPolygon())

        if let catchPoint = tuplePoint.point,
            let indexPoint = tuplePoint.index {

            self.bezierPoint = catchPoint
            self.indexBezierPoint = indexPoint
        }

        if self.bezierPoint == nil {
            self.arraySidePoint = []
            for side in view.getSidePolygon() {
                self.arraySidePoint += [side.0]
            }

            let tupleSidePoint = getIntersect(currentPoint: position, in: arraySidePoint)

            if let catchPoint = tupleSidePoint.point,
                let indexPoint = tupleSidePoint.index {

                self.bezierSidePoint = catchPoint
                self.indexBezierSidePoint = indexPoint
            }

        }
    }

    private func getIntersect(currentPoint: CGPoint, in arrayCGPoint: [CGPoint]) -> (point: CGPoint?, index: Int?) {
        //if we touch closer or equal 5 radii
        let maxDistance = CGFloat(5 * Constants.dotRadius)

        for (index, point) in arrayCGPoint.enumerated() {
            let currentDistance = CalculateMethods.getDistance(line: (currentPoint, point))

            if currentDistance <= maxDistance {
                return (point , index)
            }
        }
        return (nil, nil)
    }

}

