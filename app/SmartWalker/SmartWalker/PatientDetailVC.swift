//
//  PatientDetailVC.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 12/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit
import BEMSimpleLineGraph

class PatientDetailVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var diagnosisLabel: UILabel!
    @IBOutlet weak var diagnosisTextView: UITextView!
    
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = patient.name
        diagnosisLabel.text = patient.diagnosis?.rawValue
        patient.walkingMeasurements = [WalkingMeasurement(distance: 123, date: Date().addingTimeInterval(-6*24*3600)), WalkingMeasurement(distance: 532.4, date: Date().addingTimeInterval(-5*24*3600)), WalkingMeasurement(distance: 623, date: Date().addingTimeInterval(-4*24*3600)), WalkingMeasurement(distance: 324.5, date: Date().addingTimeInterval(-3*24*3600)), WalkingMeasurement(distance: 135, date: Date().addingTimeInterval(-2*24*3600)), WalkingMeasurement(distance: 598, date: Date().addingTimeInterval(-1*24*3600)), WalkingMeasurement(distance: 222.3, date: Date())]
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showActivitySegue", let destination = segue.destination as? ActivityGraphVC {
            destination.patient = patient
        }
    }
}
