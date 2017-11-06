//
//  ViewController.swift
//  UICollapsableTableView
//
//  Created by Himanshu Tantia on 6/11/17.
//  Copyright © 2017 Kreativ Apps, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _view: UICollapsableTableView = self.view as? UICollapsableTableView {
            _view.tableView.rowHeight = UITableViewAutomaticDimension
            _view.datasource = self
            _view.delegate = self
            _view.headerDataSource = self
            _view.enableCollapsableSections = true
        }
    }
}

extension ViewController : UITableViewDelegate {
    
}

extension ViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Cell \(indexPath)"
        return cell
    }
}

extension ViewController : UICollapsableTableViewSectionHeaderDataSource {
    func tableView(tableView: UITableView?, titleForHeaderInSection section: Int?) -> String? {
        if let secIdx = section {
            return "Header Title For Section: \(secIdx)"
        }
        return "Header Title For Section: --"
    }
}

