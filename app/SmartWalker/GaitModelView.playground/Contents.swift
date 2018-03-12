//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

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

/*
 Bodyparts - 18 elements
 {8,  "RHip"},
 {9,  "RKnee"},
 {10, "RAnkle"},
 {11, "LHip"},
 {12, "LKnee"},
 {13, "LAnkle"},
 */


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
        keypointCoordinates
        let pointsPath = UIBezierPath()
        UIColor.blue.setStroke()
        UIColor.blue.setFill()
        pointsPath.drawPoint(at: keypointCoordinates[10], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[9])
        pointsPath.drawPoint(at: keypointCoordinates[9], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[8])
        pointsPath.drawPoint(at: keypointCoordinates[8], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[11])
        pointsPath.drawPoint(at: keypointCoordinates[11], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[12])
        pointsPath.drawPoint(at: keypointCoordinates[12], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypointCoordinates[13])
        pointsPath.drawPoint(at: keypointCoordinates[13], ofSize: 5)
    }
    
}

if let keypointCoordinates = parseKeypoints(from: pointsJson), keypointCoordinates.count == 18 {
    let modelView = GaitModelView(with: keypointCoordinates)
    modelView.backgroundColor = .white
    modelView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
    PlaygroundPage.current.needsIndefiniteExecution = true
    PlaygroundPage.current.liveView = modelView
} else {
    print("Couldn't parse keypoint coordinates from JSON or invalid length")
}
