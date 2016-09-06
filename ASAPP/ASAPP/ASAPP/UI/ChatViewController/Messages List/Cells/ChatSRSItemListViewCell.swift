//
//  ChatSRSItemListViewCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatSRSItemListViewCell: UITableViewCell, ASAPPStyleable {
    
    var contentInset = UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20) {
        didSet {
            if oldValue != contentInset {
                setNeedsLayout()
            }
        }
    }
    
    var response: SRSResponse? {
        didSet {
            itemListView.itemList = response?.itemList
            setNeedsLayout()
        }
    }
    
    let itemListView = SRSItemListView()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        
        contentView.addSubview(itemListView)
        
        applyStyles(styles)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    // MARK: ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
    
        itemListView.backgroundColor = styles.backgroundColor2
        itemListView.layer.borderColor = styles.separatorColor1.CGColor
        itemListView.layer.borderWidth = 1
        itemListView.applyStyles(styles)
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemListView.frame = UIEdgeInsetsInsetRect(bounds, contentInset)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let insetSize = CGSize(width: size.width - contentInset.left - contentInset.right,
                               height: size.height - contentInset.top - contentInset.bottom)
        
        let itemListViewSize = itemListView.sizeThatFits(insetSize)
        
        return CGSize(width: size.width, height: itemListViewSize.height + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        itemListView.delegate = nil
    }
}
