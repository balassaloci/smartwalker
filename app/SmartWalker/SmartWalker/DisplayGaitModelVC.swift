//
//  DisplayGaitModelVC.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit

class DisplayGaitModelVC: UIViewController {
    var keypoints: OpenPoseKeyPointsArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gaitModelView = GaitModelView(with: keypoints)
        gaitModelView.backgroundColor = .white
        self.view = gaitModelView
    }

}
