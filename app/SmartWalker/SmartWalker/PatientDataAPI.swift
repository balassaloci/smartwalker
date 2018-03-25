//
//  PatientDataAPI.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import Foundation
import CoreGraphics

class PatientDataAPI {
    static let shared = PatientDataAPI()
    private init(){}
    
    private let baseUrl = "http://34.229.254.5:8080"
 
    func getMeasurementsFor(user userId:Int, from startDate:Date,to endDate:Date, completion: @escaping ([PatientMeasurement]?,Error?)->()){
        let getMeasurementsUrlString = "\(baseUrl)/getMeasurements/\(userId)/\(startDate.timeIntervalSince1970)/\(endDate.timeIntervalSince1970)"
        guard let getMeasurementsUrl = URL(string: getMeasurementsUrlString) else {
            DispatchQueue.main.async {
                completion(nil, APIErrors.invalidURL(getMeasurementsUrlString))
            }
            return
        }
        URLSession.shared.dataTask(with: getMeasurementsUrl, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(PatientMeasurement.dateFormatter)
                let measurements = try decoder.decode([PatientMeasurement].self, from: data)
                DispatchQueue.main.async {
                    completion(measurements, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            }
        }).resume()
    }
    
    func getExampleMeasurements(completion: @escaping ([PatientMeasurement]?,Error?)->()){
        let getMeasurementsUrl = Bundle.main.resourceURL!.appendingPathComponent("getMeasurementsResponse").appendingPathExtension("txt")
        do {
            let getMeasurementsAPIResponse = try Data(contentsOf: getMeasurementsUrl)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(PatientMeasurement.dateFormatter)
            let measurements = try decoder.decode([PatientMeasurement].self, from: getMeasurementsAPIResponse)
            DispatchQueue.main.async {
                completion(measurements, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil,error)
            }
        }
    }
    
    func measurementsWithKeypoints(_ measurements: [PatientMeasurement])->[OpenPoseKeyPointsArray] {
        let measurementsWithPose = measurements.flatMap({ measurement -> OpenPoseKeyPointsArray? in
            guard var keypoints = measurement.pose else { return nil }
            if keypoints[OpenPoseKeyPoint.LeftHip] == CGPoint(x: 0, y: 0) && keypoints[.RightHip] == CGPoint(x: 0, y: 0) {
                return nil
            }
            // Ankle should never be above Knee, if it is, it probably wasn't recognised, so just copy Knee to Ankle
            if keypoints[.LeftAnkle].y < keypoints[.LeftKnee].y {
                keypoints[.LeftAnkle] = keypoints[.LeftKnee]
            }
            if keypoints[.RightAnkle].y < keypoints[.RightKnee].y {
                keypoints[.RightAnkle] = keypoints[.RightKnee]
            }
            return keypoints
        })
        return measurementsWithPose
    }
    
    func getConditions(completion: @escaping([GaitCondition]?, Error?)->()){
        let getConditionsUrl = URL(string: "\(baseUrl)/getConditions")!
        URLSession.shared.dataTask(with: getConditionsUrl, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let conditions = try decoder.decode([GaitCondition].self, from: data)
                DispatchQueue.main.async {
                    completion(conditions, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            }
        }).resume()
    }
    
    func getExampleConditions(completion: @escaping([GaitCondition]?,Error?)->()){
        let getConditionsUrl = Bundle.main.resourceURL!.appendingPathComponent("getConditionsResponse").appendingPathExtension("txt")
        do {
            let getConditionsAPIResponse = try Data(contentsOf: getConditionsUrl)
            let conditions = try JSONDecoder().decode([GaitCondition].self, from: getConditionsAPIResponse)
            DispatchQueue.main.async {
                completion(conditions, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil,error)
            }
        }
    }
    
    func getLastDiagnosis(completion: @escaping(DiagnosticEvent?,Error?)->()){
        let getLastDiagnosisUrl = URL(string: "\(baseUrl)/getLastEvent/1")!
        URLSession.shared.dataTask(with: getLastDiagnosisUrl, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(PatientMeasurement.dateFormatter)
                let diagnosticEvent = try decoder.decode(DiagnosticEvent.self, from: data)
                DispatchQueue.main.async {
                    completion(diagnosticEvent, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            }
        }).resume()
    }
    
    func getExampleLastDiagnosis(completion: @escaping(DiagnosticEvent?,Error?)->()){
        let getLastDiagnosisUrl = Bundle.main.resourceURL!.appendingPathComponent("getLastEventResponse").appendingPathExtension("txt")
        do {
            let getLastEventAPIResponse = try Data(contentsOf: getLastDiagnosisUrl)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(PatientMeasurement.dateFormatter)
            let diagnosticEvent = try decoder.decode(DiagnosticEvent.self, from: getLastEventAPIResponse)
            DispatchQueue.main.async {
                completion(diagnosticEvent, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil,error)
            }
        }
    }
}

enum APIErrors: Error {
    case invalidURL(String)
    case invalidGripMeasurement
    case invalidPoseMeasurement
    case invalidDiagnosisValue(Int)
}
