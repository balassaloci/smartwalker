//
//  PatientTableVC.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 21/02/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit

class PatientTableVC: UITableViewController {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    let patients = [Patient(name: "John Smith", nhsNumber: 9876544321, birthday: Calendar.current.date(from: DateComponents(year: 1932))!, description: "Parkinsonian Gait", diagnosis: GaitDiagnosis.parkinsonian),
                    Patient(name: "Margaret Carpenter", nhsNumber: 9826544371, birthday: Calendar.current.date(from: DateComponents(year: 1940))!, description: "Normal gait"),
                    Patient(name: "Elizabeth Donnelly", nhsNumber: 9926584370, birthday: Calendar.current.date(from: DateComponents(year: 1950))!, description: "Hemiglephic gait",diagnosis: GaitDiagnosis.hemiplegic),
                    Patient(name: "Jack Brown", nhsNumber: 9836574321, birthday: Calendar.current.date(from: DateComponents(year: 1923))!, description: "Normal gait"),
                    Patient(name: "James McBride", nhsNumber: 9134548328, birthday: Calendar.current.date(from: DateComponents(year: 1946))!, description: "Parkinsonian Gait")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        LoginVC.addActivityIndicator(activityIndicator: activityIndicator, view: self.view)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath) as! PatientCell
        let patient = patients[indexPath.row]
        cell.nameLabel.text = patient.name
        cell.nhsNumberLabel.text = "\(patient.nhsNumber)"
        cell.ageLabel.text = patient.ageInYears
        cell.descriptionLabel.text = patient.description
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        PatientDataAPI.shared.getLastDiagnosis(completion: { diagnosticEvent, error in
            var patient = self.patients[indexPath.row]
            if let diagnosticEvent = diagnosticEvent, error == nil {
                patient.diagnosticEvent = diagnosticEvent
                patient.diagnosis = diagnosticEvent.diagnosis
            } else {
                print(error!)
            }
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: "patientDetailSegue", sender: patient)
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "patientDetailSegue", let destination = segue.destination as? PatientDetailVC, let patient = sender as? Patient {
            destination.patient = patient
        }
    }

}
