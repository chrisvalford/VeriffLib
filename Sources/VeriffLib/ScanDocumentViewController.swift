//
//  ScanDocumentViewController.swift
//  VeriffLib
//
//  Created by Christopher Alford on 30/3/22.
//

import AVFoundation
import UIKit
import Vision
import VisionKit

public protocol ScanDocumentDelegate: AnyObject {
    func scanCompleted(imageData: Data, texts: [String])
}

public class ScanDocumentViewController: UIViewController {
    public weak var delegate: ScanDocumentDelegate?
    let documentCameraViewController = VNDocumentCameraViewController()
    private var textRecognitionRequest = VNRecognizeTextRequest()
    private var faceRecognitionRequest = VNDetectFaceRectanglesRequest()
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    private var image: UIImage?
    private var documentTexts: [String] = []
    private var recognizedFaces: [VNFaceObservation] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    let maximumCandidates = 1
                    for observation in requestResults {
                        guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                        self.documentTexts.append(candidate.string)
                    }
                    self.tableView.reloadData()
                }
            }
        })
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
        faceRecognitionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            guard let requestResults = request.results as? [VNFaceObservation],
                  let image = self.image else {
                return
            }
            
            DispatchQueue.main.async {
                self.recognizedFaces = requestResults
                if let sublayers = self.imageView.layer.sublayers {
                    for layer in sublayers {
                        layer.removeFromSuperlayer()
                    }
                }
                let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: self.imageView.bounds)
                let layers: [CAShapeLayer] = self.recognizedFaces.map { face in
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
                self.imageView.image = self.image
                for layer in layers {
                    self.imageView.layer.addSublayer(layer)
                }
            }
        })
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    func processDocument(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
            try handler.perform([faceRecognitionRequest])
        } catch {
            print(error)
        }
    }
}

extension ScanDocumentViewController: VNDocumentCameraViewControllerDelegate {
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for pageNumber in 0 ..< scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            self.image = image
            processDocument(image: image)
        }
        guard let imageData = image?.pngData() else { return }
        self.delegate?.scanCompleted(imageData: imageData, texts: self.documentTexts)
        self.dismiss(animated: true)
    }
}

extension ScanDocumentViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentTexts.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTextCell", for: indexPath) as? ScanDocumentTableViewCell else {
            return UITableViewCell()
        }
        cell.scannedText?.text = documentTexts[indexPath.row]
        return cell
    }
}
