//
//  tableViewController.swift
//  TheBLUMarketKeyboard
//
//  Created by Thomas Prezioso on 7/15/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//

import Foundation
import UIKit

class tableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var tableView: UITableView  =   UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
    }
}