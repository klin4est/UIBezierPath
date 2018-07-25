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

    var vertex: CGPoint?
    var vertexIndex: Int?
    var sideDragger: CGPoint?
    var sideDraggerIndex: Int?
    var draggers = [CGPoint]()

    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        let mainFrame = self.view.frame
        let bezierView = CreatingMethods.makeBezierView(frame: mainFrame)
        let photoView = CreatingMethods.makeView(frame: mainFrame.reduce())

        self.view.addSubview(photoView)
        self.view.addSubview(bezierView)
        self.view.backgroundColor = .gray

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
            setStartValues()

            //catch drag dot
            catchDragDot(with: position, in: bezierView)

        case .changed:
            let newPosition =  sender.location(in: bezierView)

            //point alhorithm
            if let index = self.vertexIndex  {
                self.vertex = CalculateMethods.changeValue(vertexDragger: newPosition, at: index, in: bezierView)
            }

            //side alhorithm
            if let index = self.sideDraggerIndex {
                self.vertex = CalculateMethods.changeValue(sideDragger: newPosition, at: index, in: bezierView)
            }

        default:
            setStartValues()
        }
    }

    private func setStartValues() {
        self.vertex = nil
        self.vertexIndex = nil
        self.sideDragger = nil
        self.sideDraggerIndex = nil
    }

    private func catchDragDot(with position: CGPoint, in view: BezierView) {
        let tuplePoint = checkCathedDragger(near: position, in: view.getPolygon())

        if let catchPoint = tuplePoint.point,
            let indexPoint = tuplePoint.index {

            self.vertex = catchPoint
            self.vertexIndex = indexPoint
        }

        if self.vertex == nil {
            self.draggers = []
            for side in view.getSidePolygon() {
                self.draggers += [side.0]
            }

            let tupleSidePoint = checkCathedDragger(near: position, in: self.draggers)

            if let catchPoint = tupleSidePoint.point,
                let indexPoint = tupleSidePoint.index {

                self.sideDragger = catchPoint
                self.sideDraggerIndex = indexPoint
            }

        }
    }

    private func checkCathedDragger(near currentPoint: CGPoint, in draggers: [CGPoint]) -> (point: CGPoint?, index: Int?) {
        //if we touch closer or equal 5 radii
        let maxDistance = CGFloat(5 * Constants.dotRadius)

        for (index, point) in draggers.enumerated() {
            let currentDistance = CalculateMethods.getDistance(segment: (currentPoint, point))

            if currentDistance <= maxDistance {
                return (point , index)
            }
        }
        return (nil, nil)
    }

}

