//
//  GaitModelView.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 12/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit

class GaitModelView: UIView {
    var keypoints: OpenPoseKeyPointsArray
    
    var drawingColor = UIColor.blue
    var lineWidth: CGFloat = 2.0
    
    init?(with coordinates:[CGPoint]){
        guard let keypointsArray = try? OpenPoseKeyPointsArray(coordinates) else {return nil}
        keypoints = keypointsArray
        super.init(frame: CGRect.zero)
    }
    
    init(with keypoints:OpenPoseKeyPointsArray){
        self.keypoints = keypoints
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let mapCoordinatesToRect = CGAffineTransform(scaleX: rect.width, y: rect.height)
        for i in keypoints.keypointCoordinates.indices {
            keypoints.keypointCoordinates[i] = keypoints.keypointCoordinates[i].applying(mapCoordinatesToRect)
        }
        let pointsPath = UIBezierPath()
        pointsPath.lineWidth = lineWidth
        drawingColor.setStroke()
        drawingColor.setFill()
        pointsPath.drawPoint(at: keypoints[.RightAnkle], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.RightKnee])
        pointsPath.drawPoint(at: keypoints[.RightKnee], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.RightHip])
        pointsPath.drawPoint(at: keypoints[.RightHip], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftHip])
        pointsPath.drawPoint(at: keypoints[.LeftHip], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftKnee])
        pointsPath.drawPoint(at: keypoints[.LeftKnee], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftAnkle])
        pointsPath.drawPoint(at: keypoints[.LeftAnkle], ofSize: 5)
    }
}

extension UIBezierPath {
    /**
     Draw a point (filled circle), then move the path back to point
     - parameter point: center of the point to draw
     - parameter size: radius of the circle
     */
    func drawPoint(at point: CGPoint, ofSize size:CGFloat){
        self.move(to: point)
        self.addArc(withCenter: point, radius: size, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        self.fill()
        self.move(to: point)
    }
    
    /**
     Adds a line from the current point to `point`, draws it using `stroke()` then resets the path by removing all points from it
     */
    func drawLineAndResetPath(to point: CGPoint){
        self.addLine(to: point)
        self.stroke()
        self.removeAllPoints()
    }
}
