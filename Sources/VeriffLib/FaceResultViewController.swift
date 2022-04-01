//
//  FaceView.swift
//  VeriffLib
//
//  Created by Christopher Alford on 30/3/22.
//

import UIKit
import Vision

//protocol FaceResultDelegate {
//    func done()
//    func retake()
//}

public class FaceResultViewController: UIViewController {
    
    enum ButtonTag: Int {
        case done = 0
        case retake = 1
    }
    
//    var delegate: FaceResultDelegate?
    @IBOutlet var photoView: UIImageView?
    
//    @IBAction func doneTap(_ sender: UIButton) {
//        delegate?.done()
//        self.navigationController?.dismiss(animated: true)
//    }
//    
//    @IBAction func retakeTap(_ sender: UIButton) {
//        delegate?.retake()
//        self.navigationController?.dismiss(animated: true)
//    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIButton else { return }
        if segue.identifier == "unwindToScanFace" {
            let destination = segue.destination as? ScanFaceViewController
            switch ButtonTag(rawValue: button.tag) {
            case .done:
                destination?.segueMessage = "done"
            case .retake:
                destination?.segueMessage = "retake"
            default:
                return
            }
        }
    }
}
