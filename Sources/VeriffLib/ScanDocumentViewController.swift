//
//  ScanDocumentViewController.swift
//  VeriffLib
//
//  Created by Christopher Alford on 30/3/22.
//

import UIKit
import VisionKit
import Vision

public class ScanDocumentViewController: UIViewController {
    
    var resultsViewController: DocumentResultViewController?
    let documentCameraViewController = VNDocumentCameraViewController()
    var textRecognitionRequest = VNRecognizeTextRequest()
    var faceRecognitionRequest = VNDetectFaceRectanglesRequest()
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    private var documentTexts: [String] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
//        let storyboard = UIStoryboard(name: "SDK", bundle: .module)
//        resultsViewController = storyboard.instantiateViewController(withIdentifier: "documentResultViewController") as? DocumentResultViewController
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
//            guard let resultsViewController = self.resultsViewController else {
//                print("resultsViewController is not set")
//                return
//            }
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
//                    DispatchQueue.main.async {
//                        resultsViewController.addRecognizedText(recognizedText: requestResults)
//                    }
                    // Create a full transcript to run analysis on.
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
            guard let resultsViewController = self.resultsViewController else {
                print("resultsViewController is not set")
                return
            }
            guard let requestResults = request.results as? [VNFaceObservation] else {
                return
            }
            
            DispatchQueue.main.async {
                resultsViewController.addRecognizedFaces(image: self.imageView.image, recognizedFaces: requestResults)
            }
        })
        
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    func processImage(image: UIImage) {
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
            self.imageView.image = image
            processImage(image: image)
        }
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
        cell.scannedText.text = documentTexts[indexPath.row]
        return cell
    }
}

//extension ScanDocumentViewController: UITableViewDelegate {
//    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 
//    }
//}
