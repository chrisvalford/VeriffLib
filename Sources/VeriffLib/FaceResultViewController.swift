//
//  FaceView.swift
//  VeriffLib
//
//  Created by Christopher Alford on 30/3/22.
//

import UIKit
import Vision

public class FaceResultViewController: UIViewController {
    
    @IBOutlet var photoView: UIImageView?
    var image: UIImage?
    
    public override func viewDidLoad() {
        if image != nil {
            photoView?.image = image
        }
    }
}
