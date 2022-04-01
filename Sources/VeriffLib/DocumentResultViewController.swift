//
//  DocumentResultViewController.swift
//  VeriffLib
//
//  Created by Christopher Alford on 30/3/22.
//

import UIKit
import Vision
import AVFoundation

public class DocumentResultViewController: UIViewController {
    
    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var image = VeriffLib.placeholderImage
    var transcript = ""
    var recognizedFaces: [VNFaceObservation] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
        sourceImageView.image = image
        textView?.text = transcript
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if let sublayers = sourceImageView.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        
        let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: sourceImageView.bounds)
        
        let layers: [CAShapeLayer] = recognizedFaces.map { face in
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: face.boundingBox.origin.x * imageRect.width,
                                 y: imageRect.maxY - (face.boundingBox.origin.y * imageRect.height) - face.boundingBox.size.height * imageRect.height,
                                 width: face.boundingBox.size.width * imageRect.width,
                                 height: face.boundingBox.size.height * imageRect.height)
            layer.borderColor = VeriffLib.faceboundsColor.cgColor
            layer.borderWidth = 2
            layer.cornerRadius = 3
            return layer
        }
        sourceImageView.image = self.image
        for layer in layers {
            sourceImageView.layer.addSublayer(layer)
        }
    }
    
    @IBAction func doneTap(_sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true) //dismiss(animated: true)
    }
}

// MARK: RecognizedTextDataSource
extension DocumentResultViewController {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        // Create a full transcript to run analysis on.
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            transcript += candidate.string
            transcript += "\n"
        }
        textView?.text = transcript
        
    }
    
    func addRecognizedFaces(image: UIImage?, recognizedFaces: [VNFaceObservation]) {
        if image != nil {
            self.image = image!
        }
        self.recognizedFaces = recognizedFaces
    }
}
