//
//  GaitModelView.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 12/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit

let pointsJson = """
[[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [584.312, 153.303, 0.198902], [588.271, 360.965, 0.551047], [601.937, 549.081, 0.6626], [692.081, 141.552, 0.194277], [695.97, 366.867, 0.466578], [682.312, 566.683, 0.504634], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
"""

func parseKeypoints(from json:String)->[CGPoint]?{
    do {
        guard let rawKeypointsArray = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!) as? [[Double]] else {
            return nil
        }
        let keypointCoordinates = rawKeypointsArray.map({ rawCoordinates->CGPoint in
            return CGPoint(x: rawCoordinates[0], y: rawCoordinates[1])
        })
        return keypointCoordinates
    } catch {
        print(error)
        return nil
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

class GaitModelView: UIView {
    
    var keypointCoordinates = [CGPoint]()
    var maxX: CGFloat {
        return keypointCoordinates.max(by: {$0.x < $1.x})?.x ?? 0
    }
    var maxY: CGFloat {
        return keypointCoordinates.max(by: {$0.y < $1.y})?.y ?? 0
    }
    
    init(with coordinates:[CGPoint]){
        super.init(frame: CGRect.zero)
        keypointCoordinates = coordinates
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let mapCoordinatesToRect = CGAffineTransform(scaleX: rect.width/maxX, y: rect.height/maxY)
        for i in keypointCoordinates.indices {
            keypointCoordinates[i] = keypointCoordinates[i].applying(mapCoordinatesToRect)
        }
        let pointsPath = UIBezierPath()
        UIColor.blue.setStroke()
        UIColor.blue.setFill()
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightAnkle.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.RightKnee.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightKnee.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.RightHip.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightHip.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftHip.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftHip.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftKnee.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftKnee.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftAnkle.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftAnkle.rawValue], ofSize: 5)
    }
    
}

class OpenPoseKeypointsView: UIView {
    var keypointCoordinates = [CGPoint]()
    
    init(with coordinates:[CGPoint]){
        super.init(frame: CGRect.zero)
        keypointCoordinates = coordinates
        
        if let keypointCoordinates = parseKeypoints(from: pointsJson), keypointCoordinates.count == 18 {
            let keypointsArray = try? OpenPoseKeyPointsArray(keypointCoordinates)
            print(keypointsArray)
        } else {
            print("Couldn't parse keypoint coordinates from JSON or invalid length")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Coordinates should be normalized ([0,1]), so to map them
        let mapCoordinatesToRect = CGAffineTransform(scaleX: rect.width, y: rect.height)
        for i in keypointCoordinates.indices {
            keypointCoordinates[i] = keypointCoordinates[i].applying(mapCoordinatesToRect)
        }
        let pointsPath = UIBezierPath()
        UIColor.blue.setStroke()
        UIColor.blue.setFill()
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightAnkle.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.RightKnee.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightKnee.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.RightHip.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightHip.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.Neck.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.Neck.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftHip.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftHip.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftKnee.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftKnee.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftAnkle.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftAnkle.rawValue], ofSize: 5)
        pointsPath.removeAllPoints()
        pointsPath.move(to: keypointCoordinates[OpenPoseKeyPoint.LeftWrist.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftWrist.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftElbow.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftElbow.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.LeftShoulder.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.LeftShoulder.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.Neck.rawValue])
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.RightShoulder.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightShoulder.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.RightElbow.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightElbow.rawValue], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[OpenPoseKeyPoint.RightWrist.rawValue])
        pointsPath.drawPoint(at: keypointCoordinates[OpenPoseKeyPoint.RightWrist.rawValue], ofSize: 5)
    }
}
