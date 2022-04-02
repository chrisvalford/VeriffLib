//
//  ScanDocumentTableViewCell.swift
//  
//
//  Created by Christopher Alford on 1/4/22.
//

import UIKit

class ScanDocumentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scannedText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
