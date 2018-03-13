//
//  PatientMeasurement.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import Foundation
import CoreGraphics

struct PatientMeasurement: Decodable {
    let distance:Double
    let grip: GripMeasurement?
    let id:Int
    let pose: OpenPoseKeyPointsArray?
    let timestamp: Date
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    private enum CodingKeys: String, CodingKey {
        case distance, grip, id, pose, timestamp
    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        distance = try values.decode(Double.self, forKey: .distance)
        do {
            grip = try values.decode(GripMeasurement.self, forKey: .grip)
        } catch {
            grip = nil
        }
        id = try values.decode(Int.self, forKey: .id)
        do {
            pose = try values.decode(OpenPoseKeyPointsArray.self, forKey: .pose)
        } catch {
            //print("Pose empty, id: \(id)")
            pose = nil
        }
        timestamp = try values.decode(Date.self, forKey: .timestamp)
    }
}

struct GripMeasurement: Decodable {
    let leftLean: Double
    let rightLean: Double
    let leftGrip: Double
    let rightGrip: Double
    
    init(from decoder:Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode([Double].self)
        guard values.count == 4 else { throw APIErrors.invalidGripMeasurement }
        leftLean = values[0]
        rightLean = values[1]
        leftGrip = values[2]
        rightGrip = values[3]
    }
}

extension OpenPoseKeyPointsArray: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawKeypointsArray = try container.decode([[Double]].self)
        let keypointCoordinates = try rawKeypointsArray.map({ rawCoordinates->CGPoint in
            guard rawCoordinates.count == 3 else { throw APIErrors.invalidPoseMeasurement }
            return CGPoint(x: rawCoordinates[0], y: rawCoordinates[1])
        })
        try self.init(keypointCoordinates)
    }
}
