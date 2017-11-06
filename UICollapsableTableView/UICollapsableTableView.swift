//
//  UICollapsableTableView.swift
//  Kreativ Apps
//
//  Created by Himanshu Tantia on 12/9/17.
//  Copyright © 2017 Kreativ Apps, LLC. All rights reserved.
//

import UIKit

enum UICollapsableTableViewSectionHeaderState {
    case expanded, collapsed
    
    mutating func toggle() {
        if self == .expanded {
            self = .collapsed
        } else if self == .collapsed {
            self = .expanded
        }
    }
}

class UICollapsableTableView: UIView {

    var table: UITableView {
        return self.tableView
    }
    var view: UITableView {
        return self.tableView
    }
    @IBOutlet private(set) var tableView : UITableView!

    public weak var delegate: UITableViewDelegate? {
        didSet {
            if enableCollapsableSections {
                self.tableView.delegate = self
            } else {
                self.tableView.delegate = delegate
            }
        }
    }
    public weak var datasource: UITableViewDataSource? {
        didSet {
            if enableCollapsableSections {
                self.tableView.dataSource = self
            } else {
                self.tableView.dataSource = datasource
            }
        }
    }
    public weak var headerDataSource: UICollapsableTableViewSectionHeaderDataSource?
    
    public var enableCollapsableSections: Bool = false {
        willSet(newVal) {
            if newVal != enableCollapsableSections {
                sectionState = [Int : UICollapsableTableViewSectionHeaderState]()
            }
        }
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    fileprivate var sectionState : [Int : UICollapsableTableViewSectionHeaderState] = [:]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func updateState(forSection section: Int, secHeader header:UICollapsableTableViewSectionHeader) {
        var s = state(forSection: section)
        s.toggle()
        sectionState[section] = s
        header.isSelected(_state: s)
    }
    
    fileprivate func state(forSection section: Int) -> UICollapsableTableViewSectionHeaderState {
        guard let s = sectionState[section] else {
            if enableCollapsableSections {
                return .expanded
            } else {
                return .collapsed
            }
        }
        return s
    }
    
    fileprivate func externalIndexPath(forIndexPath indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row-1, section: indexPath.section)
    }
}

private typealias UICollapsableTableViewDelegateExtension = UICollapsableTableView
private typealias UICollapsableTableViewDelegateForwarding = UICollapsableTableView
private typealias UICollapsableTableViewExtensionForSectionHeaderDelegate = UICollapsableTableView

extension UICollapsableTableViewDelegateExtension : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let sectionHeader = tableView.cellForRow(at: indexPath) as! UICollapsableTableViewSectionHeader
            updateState(forSection: indexPath.section, secHeader: sectionHeader)
            tableView.reloadSections([indexPath.section], with: .fade)
        } else {
            self.delegate?.tableView?(tableView, didSelectRowAt: externalIndexPath(forIndexPath: indexPath))
        }
    }
}

extension UICollapsableTableView : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let numberOfSections = datasource?.numberOfSections?(in: tableView) else { return 1 }
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state(forSection: section) {
        case .collapsed:
            return 1
        case .expanded:
            guard let numberOfRows = datasource?.tableView(tableView, numberOfRowsInSection: section) else { return 1 }
            return numberOfRows + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let dataSource = self.datasource else { fatalError("UICollapsableTableView.datasource is nil") }
        
        guard enableCollapsableSections else {
            return dataSource.tableView(tableView, cellForRowAt: indexPath)
        }

        if indexPath.row == 0 {
            let headerView = UICollapsableTableViewSectionHeader.instanceFromNib()
            headerView.isUserInteractionEnabled = true
            headerView.dataSource = headerDataSource
            headerView.sectionIndex = indexPath.section
            headerView.setTitleLabel()
            sectionState[indexPath.section] = state(forSection: indexPath.section)
            return headerView
        } else {
            return dataSource.tableView(tableView, cellForRowAt: externalIndexPath(forIndexPath: indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
}

extension UICollapsableTableViewDelegateForwarding {
    
    // Display customization
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let sectionHeader: UICollapsableTableViewSectionHeader = cell as! UICollapsableTableViewSectionHeader
            let s = state(forSection: indexPath.section)
            sectionHeader.isSelected(_state: s)
        } else {
            self.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: externalIndexPath(forIndexPath: indexPath))
        }
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: externalIndexPath(forIndexPath: indexPath))
        }
    }
    
    @available(iOS 6.0, *)
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        delegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }
    
    // Variable height support
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != 0, let rowHeight = delegate?.tableView?(tableView, heightForRowAt: externalIndexPath(forIndexPath: indexPath)) else {
            return tableView.rowHeight
        }
        return rowHeight
    }

    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let sectionFooterHeight = delegate?.tableView?(tableView, heightForFooterInSection: section) else {
            return tableView.sectionFooterHeight
        }
        return sectionFooterHeight
    }

    
    // Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
    // If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
    @available(iOS 7.0, *)
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != 0, let estimatedRowHeight = delegate?.tableView?(tableView, estimatedHeightForRowAt: externalIndexPath(forIndexPath: indexPath)) else {
            return tableView.estimatedRowHeight
        }
        return estimatedRowHeight
    }

    @available(iOS 7.0, *)
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard let estimatedSectionFooterHeight = delegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) else {
            return tableView.estimatedSectionFooterHeight
        }
        return estimatedSectionFooterHeight
    }
    
    
//    // Section header & footer information. Views are preferred over title should you decide to provide both
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { // custom view for footer. will be adjusted to default or specified footer height
        return delegate?.tableView?(tableView, viewForFooterInSection: section)
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.row == 0 {
            let sectionHeader = tableView.cellForRow(at: indexPath) as! UICollapsableTableViewSectionHeader
            updateState(forSection: indexPath.section, secHeader: sectionHeader)
            tableView.reloadSections([indexPath.section], with: .fade)
        } else {
            self.delegate?.tableView?(tableView, accessoryButtonTappedForRowWith: externalIndexPath(forIndexPath: indexPath))
        }
    }
//
//    
//    // Selection
//    
//    // -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
//    // Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
//    @available(iOS 6.0, *)
//    optional public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
//    
//    @available(iOS 6.0, *)
//    optional public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
//    
//    @available(iOS 6.0, *)
//    optional public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
//    
//    
//    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
//    
//    @available(iOS 3.0, *)
//    optional public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?
//    
//    // Called after the user changes the selection.
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    
//    @available(iOS 3.0, *)
//    optional public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
//    
//    
//    // Editing
//    
//    // Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
//    
//    @available(iOS 3.0, *)
//    optional public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
//    
//    @available(iOS 8.0, *)
//    optional public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
//    
//    
//    // Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
//    
//    
//    // The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
//    
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
//    
//    
//    // Moving/reordering
//    
//    // Allows customization of the target row for a particular row as it is being moved/reordered
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
//    
//    
//    // Indentation
//    
//    @available(iOS 2.0, *)
//    optional public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int // return 'depth' of row for hierarchies
//    
//    
//    // Copy/Paste.  All three methods must be implemented by the delegate.
//    
//    @available(iOS 5.0, *)
//    optional public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool
//    
//    @available(iOS 5.0, *)
//    optional public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool
//    
//    @available(iOS 5.0, *)
//    optional public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?)
//    
//    
//    // Focus
//    
//    @available(iOS 9.0, *)
//    optional public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
//    
//    @available(iOS 9.0, *)
//    optional public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
//    
//    @available(iOS 9.0, *)
//    optional public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
//    
//    @available(iOS 9.0, *)
//    optional public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
}
