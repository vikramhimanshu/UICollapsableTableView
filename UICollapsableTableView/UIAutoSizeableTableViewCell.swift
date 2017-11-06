//
//  UIAutoSizeableTableViewCell.swift
//  Kreativ Apps
//
//  Created by Himanshu Tantia on 8/9/17.
//  Copyright © 2017 Kreativ Apps, LLC. All rights reserved.
//

import UIKit

class UIAutoSizeableTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withString string: String?) {
        self.textLabel?.text = string
    }

    func configure(withAttributedString attributedString: NSAttributedString?) {
        self.textLabel?.attributedText = attributedString
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
