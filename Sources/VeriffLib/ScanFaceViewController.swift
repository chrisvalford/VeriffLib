//
//  ScanFaceDetectionViewController.swift
//  VeriffLib
//
//  Created by Christopher Alford on 30/3/22.
//

import AVFoundation
import UIKit
import Vision

public class ScanFaceViewController: UIViewController {
    var sequenceHandler = VNSequenceRequestHandler()
    
    @IBOutlet var faceView: FaceView!
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var saveButton: UIButton!
    
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    var faceViewHidden = false
    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0
    
    // Single frame data
    var ciImage: CIImage?
    var landmarkObservation: VNFaceObservation?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        maxX = view.bounds.maxX
        midY = view.bounds.midY
        maxY = view.bounds.maxY
        session.startRunning()
        photoView.isHidden = true
        saveButton.isEnabled = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        photoView.isUserInteractionEnabled = true
        photoView.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension ScanFaceViewController {
    func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            fatalError("No front video camera available")
        }
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        session.addOutput(videoOutput)
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}

extension ScanFaceViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        }
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ScanFaceViewController {
    func convert(rect: CGRect) -> CGRect {
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        let absolute = point.absolutePoint(in: rect)
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        return converted
    }
    
    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        guard let points = points else {
            return nil
        }
        return points.compactMap { landmark(point: $0, to: rect) }
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.faceView.setNeedsDisplay()
            }
        }
        let box = result.boundingBox
        faceView.boundingBox = convert(rect: box)
        guard let landmarks = result.landmarks else {
            return
        }
        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEye = leftEye
        }
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEye = rightEye
        }
        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEyebrow = leftEyebrow
        }
        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEyebrow = rightEyebrow
        }
        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: result.boundingBox) {
            faceView.nose = nose
        }
        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.outerLips = outerLips
        }
        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.innerLips = innerLips
        }
        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: result.boundingBox) {
            faceView.faceContour = faceContour
        }
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
        else {
            faceView.clear()
            return
        }
        landmarkObservation = result
        updateFaceView(for: result)
    }
}

extension ScanFaceViewController {
    @IBAction func cameraTap(_ sender: UIButton) {
        self.session.stopRunning()
        takeSnapshot()
    }
    
    @IBAction func saveTap(_ sender: UIButton) {
        saveData()
    }
    
    @objc
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "SDK", bundle: Bundle.module)
        guard let faceResultViewController = storyboard.instantiateViewController(withIdentifier: "faceResultViewController") as? FaceResultViewController else { return }
        faceResultViewController.delegate = self
        navigationController?.pushViewController(faceResultViewController, animated: true)
    }
    
    private func takeSnapshot() {
        guard let ciImage = self.ciImage else { return }
        let image = UIImage(ciImage: ciImage)
        self.photoView.image = image
        self.photoView.isHidden = false
    }
    
    private func saveData() {
        guard let landmarks = landmarkObservation,
              let ciImage = self.ciImage else { return }
        let image = UIImage(ciImage: ciImage)
        guard let data = image.pngData() else { return }
        VerifyRemote.verifyIdentity(image: data, landMarks: landmarks)
    }
}

extension ScanFaceViewController: FaceResultDelegate {
    func done() {
        saveButton.isEnabled = true
    }
    
    func retake() {
        saveButton.isEnabled = false
        photoView.image = nil
        self.session.startRunning()
    }
    
    
}

