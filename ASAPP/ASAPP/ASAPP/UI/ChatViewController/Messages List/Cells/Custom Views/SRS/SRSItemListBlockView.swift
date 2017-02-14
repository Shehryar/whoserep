//
//  SRSItemListBlockView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSItemListBlockView: SRSItemListView {

    override func commonInit() {
        super.commonInit()
        
        contentInset = UIEdgeInsets(top: 25, left: 40, bottom: 25, right: 40)
    }
    
    // MARK: ASAPPStyleable
    
    override func applyStyles(_ styles: ASAPPStyles) {
        super.applyStyles(styles)
        
        backgroundColor = styles.backgroundColor2
        layer.borderColor = styles.separatorColor1.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
    }
}
