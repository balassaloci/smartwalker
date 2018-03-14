//
//  Patient.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 21/02/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import Foundation

struct Patient {
    let name:String
    let id:Int
    let nhsNumber:Int
    let birthday:Date
    let description:String
    var diagnosis:GaitDiagnosis?
    var diagnosticEvent:DiagnosticEvent?
    var walkingMeasurements:[WalkingMeasurement]
    
    var ageInYears:String {
        let yearsDiff = Calendar.current.dateComponents([.year], from: Date()).year! - Calendar.current.dateComponents([.year], from: birthday).year!
        return "\(yearsDiff) years old"
    }
    
    init(name:String,nhsNumber:Int,birthday:Date,description:String,diagnosis:GaitDiagnosis?=nil, walkingMeasurements:[WalkingMeasurement]=[WalkingMeasurement]()) {
        self.id = 1
        self.name = name
        self.nhsNumber = nhsNumber
        self.birthday = birthday
        self.description = description
        self.diagnosis = diagnosis
        self.walkingMeasurements = walkingMeasurements
        self.diagnosticEvent = nil
    }
}

enum GaitDiagnosis: Int {
    case normal, parkinsonian, hemiplegic
}

struct GaitCondition: Decodable {
    let name:String
    let id:Int
    let description:String
    
    static var knownConditions = [GaitCondition]()
}

struct WalkingMeasurement {
    let distance:Double
    let date:Date
}

struct DiagnosticEvent: Decodable {
    let confidence:Double
    let diagnosis: GaitDiagnosis
    let startOfEvent:Date
    let endOfEvent:Date
    
    private enum CodingKeys: String, CodingKey {
        case confidence, diagnosis, startOfEvent = "measurement_from", endOfEvent = "measurement_to"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.confidence = try container.decode(Double.self, forKey: .confidence)
        self.startOfEvent = try container.decode(Date.self, forKey: .startOfEvent)
        self.endOfEvent = try container.decode(Date.self, forKey: .endOfEvent)
        let diagnosisRawValue = try container.decode(Int.self, forKey: .diagnosis)
        guard let diagnosis = GaitDiagnosis(rawValue: diagnosisRawValue) else {
            throw APIErrors.invalidDiagnosisValue(diagnosisRawValue)
        }
        self.diagnosis = diagnosis
    }
}
