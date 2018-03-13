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
    
    private let displayGaitModelSegue = "gaitModelSegue"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var diagnosisLabel: UILabel!
    @IBOutlet weak var diagnosisTextView: UITextView!
    @IBAction func displayGaitModel() {
        activityIndicator.startAnimating()
        PatientDataAPI.shared.getMeasurementsFor(user: patient.id, from: Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!, to: Date(), completion: { measurements, error in
            guard let measurements = measurements, error == nil else {
                print(error!); return
            }
            guard let mostRecentModel = measurements.first(where: {$0.pose != nil})?.pose else {
                print("No keypoints measurement in the last 7 days"); return
            }
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: self.displayGaitModelSegue, sender: mostRecentModel)
        })
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = patient.name
        diagnosisLabel.text = patient.diagnosis?.rawValue
        patient.walkingMeasurements = [WalkingMeasurement(distance: 123, date: Date().addingTimeInterval(-6*24*3600)), WalkingMeasurement(distance: 532.4, date: Date().addingTimeInterval(-5*24*3600)), WalkingMeasurement(distance: 623, date: Date().addingTimeInterval(-4*24*3600)), WalkingMeasurement(distance: 324.5, date: Date().addingTimeInterval(-3*24*3600)), WalkingMeasurement(distance: 135, date: Date().addingTimeInterval(-2*24*3600)), WalkingMeasurement(distance: 598, date: Date().addingTimeInterval(-1*24*3600)), WalkingMeasurement(distance: 222.3, date: Date())]
        LoginVC.addActivityIndicator(activityIndicator: activityIndicator, view: self.view)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showActivitySegue", let destination = segue.destination as? ActivityGraphVC {
            destination.patient = patient
        } else if segue.identifier == displayGaitModelSegue, let destination = segue.destination as? DisplayGaitModelVC, let keypoints = sender as? OpenPoseKeyPointsArray {
            destination.keypoints = keypoints
        }
    }
}
