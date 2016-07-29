//
//  ChatMessagesTimeHeaderView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesTimeHeaderView: UITableViewHeaderFooterView {
    
    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16)
    
    var timeStamp: Int = 0 {
        didSet {
            textLabel?.text = String(timeStamp)
        }
    }
    
    // MARK:- Init
    
    func commonInit() {
        textLabel?.font = Fonts.latoBlackFont(withSize: 12)
        textLabel?.textColor = Colors.mediumTextColor()
        textLabel?.textAlignment = .Center
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
