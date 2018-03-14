//
//  LoginVC.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 21/02/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func login() {
        if (usernameField.text == "Doctor" && passwordField.text == "pass") {
            PatientDataAPI.shared.getConditions(completion: { conditions, error in
                if let conditions = conditions, error == nil {
                    GaitCondition.knownConditions = conditions
                } else {
                    print(error!)
                }
            })
            self.performSegue(withIdentifier: "showPatientsSegue", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Invalid username or password", message: "Please enter a valid username and password", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        usernameLabel.textColor = .white
        passwordLabel.textColor = .white
        loginButton.backgroundColor = UIColor(white:255/255,alpha:0.5)
        passwordField.isSecureTextEntry = true
        usernameField.delegate = self
        passwordField.delegate = self
        loginButton.layer.cornerRadius = loginButton.frame.height/3
        loginButton.clipsToBounds = true
    }
    
    /**
     Add an activity indicator to the specified view. Set Autolayout constraints to keep the indicator in the middle of the screen.
     - parameter activityIndicator: activityIndicator view to be added
     - parameter view: UIView to which the activity indicator should be added as a subview
     */
    static func addActivityIndicator(activityIndicator: UIActivityIndicatorView,view:UIView){
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
