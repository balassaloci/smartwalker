//
//  ActivityGraphVC.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit
import BEMSimpleLineGraph

class ActivityGraphVC: UIViewController {
    
    @IBOutlet weak var activityGraphView: BEMSimpleLineGraphView!
    @IBOutlet weak var startDateField: UITextField!
    @IBAction func editStartDate() {
        editingStartDate = true
    }
    @IBOutlet weak var endDateField: UITextField!
    @IBAction func editEndDate() {
        editingStartDate = false
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func dateChanged() {
        if editingStartDate {
            startDateField.text = dateFormatter.string(from: datePicker.date)
            startDate = datePicker.date
        } else {
            endDateField.text = dateFormatter.string(from: datePicker.date)
            endDate = datePicker.date
        }
    }
    @IBAction func refreshGraph(_ sender: UIBarButtonItem) {
        getAndDisplayData()
    }
    
    var editingStartDate = true
    var startDate = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
    var endDate = Date()
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityGraphView.delegate = self
        activityGraphView.dataSource = self
        setupGraphProperties(graph: activityGraphView)
        //startDate = Date(timeIntervalSince1970: 1520963265.43)
        //endDate = Date(timeIntervalSince1970: 1520963326.0)
        getAndDisplayData()
    }
    
    func setupGraphProperties(graph: BEMSimpleLineGraphView){
        graph.enableBezierCurve = true
        graph.enablePopUpReport = true
        graph.enableYAxisLabel = true
        graph.autoScaleYAxis = true
        graph.alwaysDisplayDots = true
        graph.enableReferenceXAxisLines = true
        graph.enableReferenceYAxisLines = true
        graph.enableReferenceAxisFrame = true
    }
    
    func getAndDisplayData(){
        PatientDataAPI.shared.getMeasurementsFor(user: patient.id, from: startDate, to: endDate, completion: { measurements, error in
            guard let measurements = measurements, error == nil else {
                print(error!); return
            }
            let dailyMeasurementsDict = measurements.reduce(into: [Date:Double](), { accResults, current in
                accResults[Calendar.current.startOfDay(for: current.timestamp), default: 0] += current.distance
            })
            let dailyWalkingMeasurements = dailyMeasurementsDict.map({WalkingMeasurement(distance: $0.value, date: $0.key)})
            self.patient.walkingMeasurements = dailyWalkingMeasurements
            self.activityGraphView.reloadGraph()
        })
    }
}

extension ActivityGraphVC: BEMSimpleLineGraphDataSource {
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

extension ActivityGraphVC: BEMSimpleLineGraphDelegate {
    func popUpSuffixForlineGraph(_ graph: BEMSimpleLineGraphView) -> String {
        return " meters"
    }
}

