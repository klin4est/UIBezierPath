//
//  CreatingMethods.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 25.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

class CreatingMethods {
    static func makeBezierView(frame: CGRect) -> BezierView {
        let newFrame = frame.reduce()
        let bezierView = BezierView(frame: newFrame)
        bezierView.backgroundColor = .clear
        bezierView.contentMode = .redraw

        return bezierView
    }

    static func makeView(frame: CGRect) -> UIView {
        let newFrame = frame.reduce(offsetValue: Constants.dotRadius)

        let newView = UIView(frame: newFrame)
        newView.backgroundColor = .yellow

        return newView
    }
}
