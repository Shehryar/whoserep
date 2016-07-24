//
//  ChatMessageEventCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessageEventCell: UITableViewCell {

    // MARK: Properties
    
    public var messageEvent: Event? {
        didSet {
            if let payload = messageEvent?.getPayload() as? EventPayload.TextMessage {
                textLabel?.text = payload.Text
            } else {
                textLabel?.text = ""
            }
        }
    }
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    func commonInit() {
        textLabel?.font = Fonts.latoRegularFont(withSize: 16)
        textLabel?.textColor = Colors.mediumTextColor()
        textLabel?.numberOfLines = 0
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    // MARK: Instance Methods
    
    func animate() {
  
    }
}
