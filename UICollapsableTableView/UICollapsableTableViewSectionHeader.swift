//
//  UICollapsableTableViewSectionHeader.swift
//  Kreativ Apps
//
//  Created by Himanshu Tantia on 18/11/16.
//  Copyright © 2016 Kreativ Apps, LLC. All rights reserved.
//

import UIKit

protocol UICollapsableTableViewSectionHeaderDataSource : class {
    func tableView(tableView: UITableView?, titleForHeaderInSection section: Int?) -> String?
}

class UICollapsableTableViewSectionHeader: UITableViewCell {
    
    var sectionIndex: Int?
    weak var dataSource: UICollapsableTableViewSectionHeaderDataSource?
    
    private var currentState: UICollapsableTableViewSectionHeaderState = .collapsed
    
    var tableView: UITableView? {
        get {
            return (self.superview as? UITableView)
        }
    }
    
    func configure(withAttributedText attributedText: NSAttributedString?) {
        self.textLabel?.attributedText = attributedText
    }
    
    func setTitleLabel() {
        let t = dataSource?.tableView(tableView: tableView, titleForHeaderInSection: sectionIndex)
        self.textLabel?.text = t
    }
    
    class func register(tableView aTableView: UITableView) {
        aTableView.register(UINib(nibName: identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    class var identifier: String {
        let identifierString = NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!
        return identifierString
    }
    
    class var nibInstance: UICollapsableTableViewSectionHeader {
        let nib = UINib(nibName: identifier, bundle: .main)
        let topLevelObjects = nib.instantiate(withOwner: nil, options: nil)
        return topLevelObjects.first as! UICollapsableTableViewSectionHeader
    }
    
    class func instanceFromNib() -> UICollapsableTableViewSectionHeader {
        let nib = UINib(nibName: identifier, bundle: .main)
        let topLevelObjects = nib.instantiate(withOwner: nil, options: nil)
        return topLevelObjects.first as! UICollapsableTableViewSectionHeader
    }
    
    class var sizeFromNib: CGSize {
        let view = nibInstance
        return view.bounds.size
    }
    
    func isSelected(_state: UICollapsableTableViewSectionHeaderState) {
        self.currentState = _state
    }
}
