//
//  ChatInfoTextCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatInfoTextCell: UITableViewCell {

    // MARK: Properties
    
    private let contentInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        opaque = true
        
        textLabel?.textAlignment = .Center
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

}
