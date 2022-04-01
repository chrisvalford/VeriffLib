//
//  FaceView.swift
//  VeriffLib
//
//  Created by Christopher Alford on 30/3/22.
//

import UIKit
import Vision

protocol FaceResultDelegate {
    func done()
    func retake()
}

public class FaceResultViewController: UIViewController {
    
    var delegate: FaceResultDelegate?
    @IBOutlet var photoView: UIImageView?
    
    @IBAction func doneTap(_ sender: UIButton) {
        delegate?.done()
        dismiss(animated: true)
    }
    
    @IBAction func retakeTap(_ sender: UIButton) {
        delegate?.retake()
        dismiss(animated: true)
    }
    
}
