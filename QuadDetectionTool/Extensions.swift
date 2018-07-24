//
//  Extensions.swift
//  QuadDetectionTool
//
//  Created by Stanislav Astakhov on 24.07.2018.
//  Copyright © 2018 Stanislav Astakhov. All rights reserved.
//

import UIKit

extension CGPoint {
    public func getMiddle(to position: CGPoint) -> CGPoint {
        let x = (self.x + position.x) / 2
        let y = (self.y + position.y) / 2

        return CGPoint(x: x, y: y)
    }

    public func moveByXY(deltaX: CGFloat = 0.0, deltaY: CGFloat = 0.0) -> CGPoint {
        return CGPoint(x: self.x + deltaX, y: self.y + deltaY)
    }

    public func getCorrectPosition(in frame: CGRect) -> CGPoint {

        let gapXY = CGFloat(Constants.dotRadius)
        let x = min(max(self.x, gapXY), CGFloat(frame.width - gapXY))
        let y = min(max(self.y, gapXY), CGFloat(frame.height - gapXY))

        return CGPoint(x: x, y: y)
    }
}

extension CGRect {
    public func reduce(indentWidth: Double, indentHeight: Double, offsetValue: Double = 0.0) -> CGRect {

        if offsetValue == 0.0 {
            let newWidth = CalculateMethods.reduceValue(self.width, at: indentWidth)
            let newHeight = CalculateMethods.reduceValue(self.height, at: indentHeight)

            return CGRect(x: indentWidth, y: indentHeight, width: newWidth, height: newHeight)
        } else {
            let newWidth = CalculateMethods.reduceValue(self.width, at: offsetValue)
            let newHeight = CalculateMethods.reduceValue(self.height, at: offsetValue)

            return CGRect(x: indentWidth + offsetValue, y: indentHeight + offsetValue, width: newWidth, height: newHeight)
        }
    }

}
