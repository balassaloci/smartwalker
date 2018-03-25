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
        let startDate = patient.diagnosticEvent?.startOfEvent ?? Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!
        let endDate = patient.diagnosticEvent?.endOfEvent ?? Date()
        PatientDataAPI.shared.getExampleMeasurements(completion: { measurements, error in
        //PatientDataAPI.shared.getMeasurementsFor(user: patient.id, from: startDate, to: endDate, completion: { measurements, error in
            guard let measurements = measurements, error == nil else {
                print(error!); return
            }
            let measurementsWithPose = PatientDataAPI.shared.measurementsWithKeypoints(measurements)
            self.activityIndicator.stopAnimating()
            if measurementsWithPose.count > 0 {
                self.performSegue(withIdentifier: self.displayGaitModelSegue, sender: measurementsWithPose)
            } else {
                print("No pose measurements for event")
                let alertController = UIAlertController(title: "No gait model available", message: "There is no gait model available at the moment, please try again later", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = patient.name
        if let diagnosis = patient.diagnosis {
            print(patient.diagnosticEvent as Any)
            let condition = GaitCondition.knownConditions[diagnosis.rawValue-1]
            if let confidence = patient.diagnosticEvent?.confidence {
                let percentageFormatter = NumberFormatter()
                percentageFormatter.numberStyle = .percent
                percentageFormatter.maximumFractionDigits = 2
                let confidencePercentageString = percentageFormatter.string(for: confidence) ?? "\(confidence*100)%"
                diagnosisLabel.text = "\(condition.name) - \(confidencePercentageString)"
            } else {
                diagnosisLabel.text = condition.name
            }
            diagnosisTextView.text = condition.description
        }
        patient.walkingMeasurements = [WalkingMeasurement(distance: 123, date: Date().addingTimeInterval(-6*24*3600)), WalkingMeasurement(distance: 532.4, date: Date().addingTimeInterval(-5*24*3600)), WalkingMeasurement(distance: 623, date: Date().addingTimeInterval(-4*24*3600)), WalkingMeasurement(distance: 324.5, date: Date().addingTimeInterval(-3*24*3600)), WalkingMeasurement(distance: 135, date: Date().addingTimeInterval(-2*24*3600)), WalkingMeasurement(distance: 598, date: Date().addingTimeInterval(-1*24*3600)), WalkingMeasurement(distance: 222.3, date: Date())]
        LoginVC.addActivityIndicator(activityIndicator: activityIndicator, view: self.view)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showActivitySegue", let destination = segue.destination as? ActivityGraphVC {
            destination.patient = patient
        } else if segue.identifier == displayGaitModelSegue, let destination = segue.destination as? DisplayGaitModelVC, let keypoints = sender as? [OpenPoseKeyPointsArray] /*OpenPoseKeyPointsArray*/ {
            destination.keypointsTimeline = keypoints
        }
    }
}
