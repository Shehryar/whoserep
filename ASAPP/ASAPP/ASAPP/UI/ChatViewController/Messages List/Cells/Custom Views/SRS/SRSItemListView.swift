//
//  SRSItemListView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol SRSItemListViewDelegate {
    func itemListView(itemListView: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem)
}

class SRSItemListView: StackView, ASAPPStyleable {
    
    var srsItems: /** Must be SRS** Classes */ [AnyObject]? {
        didSet {
            if let srsItems = srsItems {
                createSubviewsForCurrentResponse()
            } else {
                clear()
            }
        }
    }
    
    var delegate: SRSItemListViewDelegate?
    
    // MARK: ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        setNeedsLayout()
    }
    
    // MARK: Creating the Views
    
    func createSubviewsForCurrentResponse() {
        guard let items = srsItems else { return }
        
        clear()

        var createdViews = [UIView]()
        for item in items {
            // Button Item
            if let buttonItem = item as? SRSButtonItem {
                let button = Button()
                button.title = buttonItem.title
                button.foregroundColor = styles.accentColor
                button.font = styles.buttonFont
                button.onTap = { [weak self] in
                    if let strongSelf = self {
                        strongSelf.delegate?.itemListView(strongSelf, didSelectButtonItem: buttonItem)
                    }
                }
                createdViews.append(button)
            }
            
            // Label Item
            else if let labelItem = item as? SRSLabelItem {
                let label = UILabel()
                label.numberOfLines = 0
                label.lineBreakMode = .ByTruncatingTail
                label.textColor = styles.foregroundColor2
                label.font = styles.detailFont
                label.textAlignment = .Center
                label.text = labelItem.text
                createdViews.append(label)
            }
                
            // Info Item
            else if let infoItem = item as? SRSInfoItem {
                let infoItemView = SRSInfoItemView()
                infoItemView.applyStyles(styles)
                infoItemView.infoItem = infoItem
                createdViews.append(infoItemView)
            }
                
            // Separator Item
            else if item is SRSSeparatorItem {
                let separatorView = SRSSeparatorView()
                separatorView.applyStyles(styles)
                createdViews.append(separatorView)
            }
            
            // Filler Item
            else if item is SRSFillerItem {
                let fillerView = SRSFillerView()
                fillerView.applyStyles(styles)
                createdViews.append(fillerView)
            }
                
            // Loader Bar Item
            else if let loaderBarItem = item as? SRSLoaderBarItem {
                let loaderBarView = SRSLoaderBarView()
                loaderBarView.applyStyles(styles)
                loaderBarView.loaderItem = loaderBarItem
                createdViews.append(loaderBarView)
            }
                
            // Item List
            else if let itemList = item as? SRSItemList {
                let itemListView = SRSItemListView()
                itemListView.contentInset = UIEdgeInsetsZero
                itemListView.applyStyles(styles)
                itemListView.srsItems = itemList.items
                if itemList.orientation == .Vertical {
                    itemListView.orientation = .Vertical
                } else {
                    itemListView.orientation = .Horizontal
                }
                createdViews.append(itemListView)
            }
        }
        addArrangedViews(createdViews)
    }
}
