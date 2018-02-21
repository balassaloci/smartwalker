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
    
    var ageInYears:String {
        let yearsDiff = Calendar.current.dateComponents([.year], from: Date()).year! - Calendar.current.dateComponents([.year], from: birthday).year!
        return "\(yearsDiff) years old"
    }
}
