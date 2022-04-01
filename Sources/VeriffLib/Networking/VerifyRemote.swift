//
//  File.swift
//  
//
//  Created by Christopher Alford on 1/4/22.
//

import Foundation
import Vision

enum VerifyState {
    case verified
    case failed
}

class VerifyRemote {
    class func verifyIdentity(image: Data, landMarks: VNFaceObservation, completion: (VerifyState, Error?) -> Void) {
        print("Verifying face data")
        completion(.verified, nil)
    }
}
