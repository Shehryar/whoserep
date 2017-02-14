//
//  SRSItemListView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol SRSItemListViewDelegate: class {
    func itemListView(_ itemListView: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem);
}

class SRSItemListView: UIView {

    var itemList: SRSItemList? {
        didSet {
            itemListView.contentItems = itemList?.contentItems
            setNeedsLayout()
        }
    }
    
    weak var delegate: SRSItemListViewDelegate?
    
    private let itemListView = SRSItemListContentView()
    private let buttonsView = SRSInlineButtonsContainer()
    
    // MARK: Initialization
    
    func commonInit() {
        itemListView.contentInset = UIEdgeInsets(top: 25, left: 40, bottom: 25, right: 40)
        itemListView.clipsToBounds = true
        addSubview(itemListView)
        
        buttonsView.clipsToBounds = true
        addSubview(buttonsView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
    
        backgroundColor = styles.backgroundColor2
        layer.borderColor = styles.separatorColor1.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
        
        itemListView.applyStyles(styles)
        buttonsView.applyStyles(styles)
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> (/* ItemListView */ CGRect, /* Buttons View */ CGRect) {
        let itemListHeight = ceil(itemListView.sizeThatFits(CGSize(width: size.width, height: 0)).height)
        let itemListFrame = CGRect(x: 0, y: 0, width: size.width, height: itemListHeight)
        
        let buttonsViewHeight = ceil(buttonsView.sizeThatFits(CGSize(width: size.width, height: 0)).height)
        let buttonsViewTop = itemListFrame.maxY
        let buttonsViewFrame = CGRect(x: 0, y: buttonsViewTop, width: size.width, height: buttonsViewHeight)
        
        return (itemListFrame, buttonsViewFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (itemsListFrame, buttonsViewFrame) = getFramesThatFit(bounds.size)
        itemListView.frame = itemsListFrame
        buttonsView.frame = buttonsViewFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (itemsListFrame, buttonsViewFrame) = getFramesThatFit(size)
        let height = buttonsViewFrame.maxY
        
        return CGSize(width: size.width, height: height)
    }
}
