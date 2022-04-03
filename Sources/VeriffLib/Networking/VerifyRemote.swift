//
//  File.swift
//  
//
//  Created by Christopher Alford on 1/4/22.
//

import Foundation
import Vision

public enum VerifyState {
    case verified
    case failed
}

public class VerifyRemote {
    public class func verifyIdentity(imageData: Data, landMarks: VNFaceObservation, completion: (VerifyState, Error?) -> Void) {
        print("Verifying face data")
        completion(.verified, nil)
    }
    
    public class func verifyDocument(imageData: Data, texts: [String], completion: (VerifyState, Error?) -> Void) {
        print("Verifying document data")
        completion(.verified, nil)
    }
}
