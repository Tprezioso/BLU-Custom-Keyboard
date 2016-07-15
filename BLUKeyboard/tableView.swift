//
//  tableView.swift
//  TheBLUMarketKeyboard
//
//  Created by Thomas Prezioso on 7/15/16.
//  Copyright © 2016 Thomas Prezioso. All rights reserved.
//

import UIKit
import Social
import Accounts

class tableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tweetTableView: UITableView!
    var tableView: UITableView  =   UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
    var dataSource = [AnyObject]()
}
