//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let pointsJson = """
[[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [584.312, 153.303, 0.198902], [588.271, 360.965, 0.551047], [601.937, 549.081, 0.6626], [692.081, 141.552, 0.194277], [695.97, 366.867, 0.466578], [682.312, 566.683, 0.504634], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0],[0,0,0]]
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

//: ![OpenPose Keypoints](keypoints_pose.png)

/**
 Name of the available OpenPose keypoints with their corresponding rawValues (starting from 0) representing their indexes in the JSON output array from OpenPose
 */
enum OpenPoseKeyPoint:Int {
    case Nose, Neck, RightShoulder, RightElbow, RightWrist, LeftShoulder, LeftElbow, LeftWrist, RightHip, RightKnee, RightAnkle, LeftHip, LeftKnee, LeftAnkle, RightEye, LeftEye, RightEar, LeftEar, Background
    
    // Find the last existing rawValue, assumes that the first case has rawValue 0 and that rawValues are incremented by 1
    static let maxRawValue: OpenPoseKeyPoint.RawValue = {
        var maxRawVal = 0
        while OpenPoseKeyPoint(rawValue: maxRawVal) != nil {
            maxRawVal += 1
        }
        return maxRawVal
    }()
    
    static let rawValues: [OpenPoseKeyPoint.RawValue] = {
        var rawValues = [OpenPoseKeyPoint.RawValue]()
        var currentRawValue = 0
        while OpenPoseKeyPoint(rawValue: currentRawValue) != nil {
            rawValues.append(currentRawValue)
            currentRawValue += 1
        }
        return rawValues
    }()
}

extension OpenPoseKeyPoint: Hashable {} //Needed for O(1) subscripting

extension OpenPoseKeyPoint: Comparable {
    static func <(lhs: OpenPoseKeyPoint, rhs: OpenPoseKeyPoint) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension OpenPoseKeyPoint: Strideable {
    typealias Stride = Int
    func distance(to other: OpenPoseKeyPoint) -> OpenPoseKeyPoint.Stride {
        return self.rawValue - other.rawValue
    }
    
    func advanced(by n: OpenPoseKeyPoint.Stride) -> OpenPoseKeyPoint {
        return OpenPoseKeyPoint(rawValue: (self.rawValue+n)%OpenPoseKeyPoint.maxRawValue)!
    }
}

/**
 Collection type holding OpenPoseKeyPoint instances, its indexes can only be OpenPoseKeyPoint instances and to create one, all keypoints need to be present
 Its values should be CGPoints representing the coordinates of the keypoints
 */
struct OpenPoseKeyPointsArray: Collection, RandomAccessCollection {
    typealias Element = CGPoint
    typealias Index = OpenPoseKeyPoint
    
    var keypointCoordinates: [Element] = Array<Element>.init(repeating: Element.init(), count: OpenPoseKeyPoint.rawValues.count)
    var startIndex: Index {
        return OpenPoseKeyPoint(rawValue: keypointCoordinates.startIndex)!
    }
    var endIndex: Index {
        return OpenPoseKeyPoint(rawValue: keypointCoordinates.startIndex)!
    }
    
    subscript (position: Index) -> Element {
        get {
            return keypointCoordinates[position.rawValue]
        }
        set {
            keypointCoordinates[position.rawValue] = newValue
        }
    }
    
    func index(after i: Index) -> Index {
        return Index(rawValue: keypointCoordinates.index(after: i.rawValue))!
    }
    
    private init(){}
    init?<C:Collection>(_ collection:C) where C.Element == CGPoint, C.Index == Int {
        guard collection.indices.map({$0}) == OpenPoseKeyPoint.rawValues else {return nil}
        for (index, element) in collection.enumerated() {
            self.keypointCoordinates[index] = element
        }
    }
}

class GaitModelView: UIView {
    
    var keypoints: OpenPoseKeyPointsArray
    var maxX: CGFloat {
        return keypoints.keypointCoordinates.max(by: {$0.x < $1.x})?.x ?? 0
    }
    var maxY: CGFloat {
        return keypoints.keypointCoordinates.max(by: {$0.y < $1.y})?.y ?? 0
    }
    
    init?(with coordinates:[CGPoint]){
        guard let keypointsArray = OpenPoseKeyPointsArray(coordinates) else {return nil}
        keypoints = keypointsArray
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let mapCoordinatesToRect = CGAffineTransform(scaleX: rect.width/maxX, y: rect.height/maxY)
        for i in keypoints.keypointCoordinates.indices {
            keypoints.keypointCoordinates[i] = keypoints.keypointCoordinates[i].applying(mapCoordinatesToRect)
        }
        let pointsPath = UIBezierPath()
        UIColor.blue.setStroke()
        UIColor.blue.setFill()
        keypoints[.RightAnkle]
        pointsPath.drawPoint(at: keypoints[.RightAnkle], ofSize: 5)
        keypoints[.RightKnee]
        pointsPath.drawLineAndResetPath(to: keypoints[.RightKnee])
        pointsPath.drawPoint(at: keypoints[.RightKnee], ofSize: 5)
        keypoints[.RightHip]
        pointsPath.drawLineAndResetPath(to: keypoints[.RightHip])
        pointsPath.drawPoint(at: keypoints[.RightHip], ofSize: 5)
        keypoints[.LeftHip]
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftHip])
        pointsPath.drawPoint(at: keypoints[.LeftHip], ofSize: 5)
        keypoints[.LeftKnee]
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftKnee])
        pointsPath.drawPoint(at: keypoints[.LeftKnee], ofSize: 5)
        keypoints[.LeftAnkle]
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftAnkle])
        pointsPath.drawPoint(at: keypoints[.LeftAnkle], ofSize: 5)
    }
}

class OpenPoseKeypointsView: UIView {
    var keypoints: OpenPoseKeyPointsArray
    
    init?(with coordinates:[CGPoint]){
        guard let keypointsArray = OpenPoseKeyPointsArray(coordinates) else {return nil}
        keypoints = keypointsArray
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Drawing is fucked up if any of the points are missing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Coordinates should be normalized ([0,1]), so to map them
        //let mapCoordinatesToRect = CGAffineTransform(scaleX: rect.width, y: rect.height)
        //Only needed until the points are not normalized
        var maxX: CGFloat {
            return keypoints.keypointCoordinates.max(by: {$0.x < $1.x})?.x ?? 0
        }
        var maxY: CGFloat {
            return keypoints.keypointCoordinates.max(by: {$0.y < $1.y})?.y ?? 0
        }
        let mapCoordinatesToRect = CGAffineTransform(scaleX: rect.width/maxX, y: rect.height/maxY)
        // Until needed END
        for i in keypoints.indices {
            keypoints[i] = keypoints[i].applying(mapCoordinatesToRect)
        }
        keypoints
        let pointsPath = UIBezierPath()
        UIColor.blue.setStroke()
        UIColor.blue.setFill()
        pointsPath.drawPoint(at: keypoints[.RightAnkle], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.RightKnee])
        pointsPath.drawPoint(at: keypoints[.RightKnee], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.RightHip])
        pointsPath.drawPoint(at: keypoints[.RightHip], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.Neck])
        pointsPath.drawPoint(at: keypoints[.Neck], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftHip])
        pointsPath.drawPoint(at: keypoints[.LeftHip], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftKnee])
        pointsPath.drawPoint(at: keypoints[.LeftKnee], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftAnkle])
        pointsPath.drawPoint(at: keypoints[.LeftAnkle], ofSize: 5)
        pointsPath.removeAllPoints()
        pointsPath.move(to: keypoints[.LeftWrist])
        pointsPath.drawPoint(at: keypoints[.LeftWrist], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftElbow])
        pointsPath.drawPoint(at: keypoints[.LeftElbow], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.LeftShoulder])
        pointsPath.drawPoint(at: keypoints[.LeftShoulder], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.Neck])
        pointsPath.drawLineAndResetPath(to: keypoints[.RightShoulder])
        pointsPath.drawPoint(at: keypoints[.RightShoulder], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.RightElbow])
        pointsPath.drawPoint(at: keypoints[.RightElbow], ofSize: 5)
        pointsPath.drawLineAndResetPath(to: keypoints[.RightWrist])
        pointsPath.drawPoint(at: keypoints[.RightWrist], ofSize: 5)
    }
}

if let keypointCoordinates = parseKeypoints(from: pointsJson) {
    let keypointsArray = OpenPoseKeyPointsArray(keypointCoordinates)
    keypointsArray
    let modelView = GaitModelView(with: keypointCoordinates)
    modelView?.keypoints
    modelView?.backgroundColor = .white
    modelView?.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
    PlaygroundPage.current.needsIndefiniteExecution = true
    PlaygroundPage.current.liveView = modelView
} else {
    print("Couldn't parse keypoint coordinates from JSON or invalid length")
}
