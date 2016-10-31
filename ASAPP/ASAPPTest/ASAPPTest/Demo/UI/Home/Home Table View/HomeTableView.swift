//
//  HomeTableView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class HomeTableView: UIView {

    var contentInset: UIEdgeInsets = .zero {
        didSet {
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
        }
    }
    
    // MARK: Private Properties
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor.clear
        
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
    }
}

// MARK:- UITableViewDataSource

extension HomeTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK:- UITableViewDelegate

extension HomeTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
