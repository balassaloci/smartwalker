//
//  DisplayGaitModelVC.swift
//  SmartWalker
//
//  Created by Pásztor Dávid on 13/03/2018.
//  Copyright © 2018 Pásztor Dávid. All rights reserved.
//

import UIKit

class DisplayGaitModelVC: UIViewController {
    @IBOutlet weak var playPauseButton: UIBarButtonItem!
    @IBAction func playPause(_ sender: UIBarButtonItem) {
        if gaitModelImageView.isAnimating {
            //gaitModelImageView.stopAnimating()
            //playPauseButton =
        } else {
            //gaitModelImageView.stopAnimating()
        }
    }
    var keypointsTimeline: [OpenPoseKeyPointsArray]!
    let gaitModelImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Loading too many images would lead to memory issues
        keypointsTimeline = keypointsTimeline.count > 50 ? Array(keypointsTimeline[0..<25]) : keypointsTimeline
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
