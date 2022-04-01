import UIKit
import UniformTypeIdentifiers

public struct VeriffLib {
    
    public static let libBundle = Bundle.module
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    // Configuarable vars
    public static var faceboundsColor: UIColor = .red
    public static var placeholderImage: UIImage = UIImage(named: "Placeholder", in: libBundle, with: nil)!
}


