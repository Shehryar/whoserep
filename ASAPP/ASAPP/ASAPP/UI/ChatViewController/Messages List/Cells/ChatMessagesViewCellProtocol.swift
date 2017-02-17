//
//  ChatMessagesViewCellProtocol.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatMessagesViewCell {
    
    var contentInset: UIEdgeInsets { get set }

    func styleCell(listPosition: MessageListPosition, isReply: Bool)
}
