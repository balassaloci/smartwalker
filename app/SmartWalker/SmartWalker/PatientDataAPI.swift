//
//  PatientDataAPI.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import Foundation

class PatientDataAPI {
    static let shared = PatientDataAPI()
    private init(){}
    
    private let baseUrl = "http://35.153.226.7:8080"
    
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
}

enum APIErrors: Error {
    case invalidURL(String)
    case invalidGripMeasurement
    case invalidPoseMeasurement
    case invalidDiagnosisValue(Int)
}
