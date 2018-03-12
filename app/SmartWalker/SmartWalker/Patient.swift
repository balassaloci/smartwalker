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
    let nhsNumber:Int
    let birthday:Date
    let description:String
    var diagnosis:GaitDiagnosis?
    var walkingMeasurements:[WalkingMeasurement]
    
    var ageInYears:String {
        let yearsDiff = Calendar.current.dateComponents([.year], from: Date()).year! - Calendar.current.dateComponents([.year], from: birthday).year!
        return "\(yearsDiff) years old"
    }
    
    init(name:String,nhsNumber:Int,birthday:Date,description:String,diagnosis:GaitDiagnosis?=nil, walkingMeasurements:[WalkingMeasurement]=[WalkingMeasurement]()) {
        self.name = name
        self.nhsNumber = nhsNumber
        self.birthday = birthday
        self.description = description
        self.diagnosis = diagnosis
        self.walkingMeasurements = walkingMeasurements
    }
}

enum GaitDiagnosis: String {
    case parkinsonian, normal
}

struct WalkingMeasurement {
    let distance:Double
    let date:Date
}
