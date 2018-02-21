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
        self.performSegue(withIdentifier: "showPatientsSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        usernameLabel.textColor = .white
        passwordLabel.textColor = .white
        loginButton.backgroundColor = UIColor(white:255/255,alpha:0.5)
        /*
        loginButton.layer.cornerRadius = loginButton.frame.height/3
        loginButton.clipsToBounds = true
         */
    }

}
