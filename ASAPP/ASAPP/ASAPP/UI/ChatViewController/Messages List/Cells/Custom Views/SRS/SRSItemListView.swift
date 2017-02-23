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
            buttonsView.buttonItems = itemList?.inlineButtonItems
            setNeedsLayout()
        }
    }
    
    var event: Event?
    
    weak var delegate: SRSItemListViewDelegate?
    
    private let itemListView = SRSItemListContentView()
    private let buttonsView = SRSInlineButtonsView()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = ASAPP.styles.backgroundColor2
        layer.borderColor = ASAPP.styles.separatorColor1.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
        
        itemListView.contentInset = UIEdgeInsets(top: 25, left: 40, bottom: 25, right: 40)
        itemListView.clipsToBounds = true
        addSubview(itemListView)
    
        buttonsView.clipsToBounds = true
        buttonsView.onButtonItemTap =  { [weak self] (buttonItem) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.itemListView(strongSelf, didSelectButtonItem: buttonItem)
        }
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
        let (_, buttonsViewFrame) = getFramesThatFit(size)
        let height = buttonsViewFrame.maxY
        
        return CGSize(width: size.width, height: height)
    }
}
