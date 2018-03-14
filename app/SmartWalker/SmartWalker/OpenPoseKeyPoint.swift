//
//  OpenPoseKeyPoint.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import Foundation
import CoreGraphics

/**
 Name of the available OpenPose keypoints with their corresponding rawValues (starting from 0) representing their indexes in the JSON output array from OpenPose
 */
enum OpenPoseKeyPoint:Int {
    case Nose, Neck, RightShoulder, RightElbow, RightWrist, LeftShoulder, LeftElbow, LeftWrist, RightHip, RightKnee, RightAnkle, LeftHip, LeftKnee, LeftAnkle, RightEye, LeftEye, RightEar, LeftEar
    
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
    init<C:Collection>(_ collection:C) throws where C.Element == CGPoint, C.Index == Int {
        guard collection.indices.map({$0}) == OpenPoseKeyPoint.rawValues else {
            throw APIErrors.invalidPoseMeasurement }
        for (index, element) in collection.enumerated() {
            keypointCoordinates[index] = element
        }
    }
}

