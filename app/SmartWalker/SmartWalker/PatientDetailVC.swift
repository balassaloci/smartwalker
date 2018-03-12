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
    @IBOutlet weak var activityGraphView: BEMSimpleLineGraphView!
    
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = patient.name
        diagnosisLabel.text = patient.diagnosis?.rawValue
        patient.walkingMeasurements = [WalkingMeasurement(distance: 123, date: Date().addingTimeInterval(-6*24*3600)), WalkingMeasurement(distance: 532.4, date: Date().addingTimeInterval(-5*24*3600)), WalkingMeasurement(distance: 623, date: Date().addingTimeInterval(-4*24*3600)), WalkingMeasurement(distance: 324.5, date: Date().addingTimeInterval(-3*24*3600)), WalkingMeasurement(distance: 135, date: Date().addingTimeInterval(-2*24*3600)), WalkingMeasurement(distance: 598, date: Date().addingTimeInterval(-1*24*3600)), WalkingMeasurement(distance: 222.3, date: Date())]
        activityGraphView.delegate = self
        activityGraphView.dataSource = self
        setupGraphProperties(graph: activityGraphView)
        activityGraphView.reloadGraph()
    }
    
    func setupGraphProperties(graph: BEMSimpleLineGraphView){
        graph.enableBezierCurve = true
        graph.enablePopUpReport = true
        //graph.enableTouchReport = true
        graph.enableYAxisLabel = true
        graph.autoScaleYAxis = true
        graph.alwaysDisplayDots = true
        graph.enableReferenceXAxisLines = true
        graph.enableReferenceYAxisLines = true
        graph.enableReferenceAxisFrame = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension PatientDetailVC: BEMSimpleLineGraphDataSource {
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> UInt {
        return UInt(patient.walkingMeasurements.count)
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: UInt) -> CGFloat {
        return CGFloat(patient.walkingMeasurements[Int(index)].distance)
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: UInt) -> String? {
        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        return df.string(from: patient.walkingMeasurements[Int(index)].date)
    }
}

extension PatientDetailVC: BEMSimpleLineGraphDelegate {
    func popUpSuffixForlineGraph(_ graph: BEMSimpleLineGraphView) -> String {
        return " meters"
    }
}
