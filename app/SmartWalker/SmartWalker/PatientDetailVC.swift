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
        PatientDataAPI.shared.getMeasurementsFor(user: patient.id, from: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!, to: Date(), completion: { measurements, error in
            guard let measurements = measurements, error == nil else {
                print(error!); return
            }
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
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: self.displayGaitModelSegue, sender: measurementsWithPose)
        })
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = patient.name
        if let diagnosis = patient.diagnosis {
            diagnosisLabel.text = GaitCondition.knownConditions[diagnosis.rawValue].name
            diagnosisTextView.text = GaitCondition.knownConditions[diagnosis.rawValue].description
        }
        patient.walkingMeasurements = [WalkingMeasurement(distance: 123, date: Date().addingTimeInterval(-6*24*3600)), WalkingMeasurement(distance: 532.4, date: Date().addingTimeInterval(-5*24*3600)), WalkingMeasurement(distance: 623, date: Date().addingTimeInterval(-4*24*3600)), WalkingMeasurement(distance: 324.5, date: Date().addingTimeInterval(-3*24*3600)), WalkingMeasurement(distance: 135, date: Date().addingTimeInterval(-2*24*3600)), WalkingMeasurement(distance: 598, date: Date().addingTimeInterval(-1*24*3600)), WalkingMeasurement(distance: 222.3, date: Date())]
        LoginVC.addActivityIndicator(activityIndicator: activityIndicator, view: self.view)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showActivitySegue", let destination = segue.destination as? ActivityGraphVC {
            destination.patient = patient
        } else if segue.identifier == displayGaitModelSegue, let destination = segue.destination as? DisplayGaitModelVC, let keypoints = sender as? [OpenPoseKeyPointsArray] /*OpenPoseKeyPointsArray*/ {
            //destination.keypoints = keypoints
            destination.keypointsTimeline = keypoints
        }
    }
}
