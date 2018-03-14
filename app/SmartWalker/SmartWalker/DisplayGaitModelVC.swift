//
//  DisplayGaitModelVC.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit

class DisplayGaitModelVC: UIViewController {
    var keypointsTimeline: [OpenPoseKeyPointsArray]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gaitModelImageView = UIImageView()
        gaitModelImageView.animationImages = keypointsTimeline.map({ keypoints -> UIImage in
            let gaitModelView = GaitModelView(with: keypoints)
            gaitModelView.backgroundColor = .white
            gaitModelView.frame = self.view.frame
            return UIImage(view: gaitModelView)
        })
        gaitModelImageView.animationDuration = Double(keypointsTimeline.count)/15
        self.view = gaitModelImageView
        gaitModelImageView.startAnimating()
    }

}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
