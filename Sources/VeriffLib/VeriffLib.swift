import UIKit
//import UniformTypeIdentifiers
import Vision

// Notification identifiers
//let faceDetectionCompletionKey = "com.anapp4that.faceDetectionCompletion"
//let documentDetectionCompletionKey = "com.anapp4that.documentDetectionCompletion"
//public let faceCompletionNotification = Notification.Name(rawValue: faceDetectionCompletionKey)
//public let documentCompletionNotification = Notification.Name(rawValue: documentDetectionCompletionKey)

public typealias faceDetectionCompleted = (_ imageData: Data?, _ error: Error?) -> Void

public struct VeriffLib {
    
    public static let libBundle = Bundle.module
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    // Configuarable vars
    public static var faceboundsColor: UIColor = .red
    public static var placeholderImage: UIImage = UIImage(named: "Placeholder", in: libBundle, with: nil)!
}

public struct FaceData {
    public let imageData: Data
    public let landmarks: VNFaceObservation
    public let type: String
}
