//
//  SRSItemListView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSItemListView: StackView, ASAPPStyleable {
    
    var itemList: SRSItemList? {
        didSet {
            if let itemList = itemList {
                if oldValue != itemList {
                    createSubviewsForCurrentResponse()
                }
            } else {
                clear()
            }
        }
    }
    
    // MARK: ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        setNeedsLayout()
    }
    
    // MARK: Creating the Views
    
    func createSubviewsForCurrentResponse() {
        guard let items = itemList?.items else { return }
        
        clear()

        var createdViews = [UIView]()
        for item in items {
            // Button Item
            if let buttonItem = item as? SRSButtonItem {
                let button = Button()
                button.title = buttonItem.title
                button.foregroundColor = styles.accentColor
                button.font = styles.buttonFont
                createdViews.append(button)
            }
            
            // Label Item
            else if let labelItem = item as? SRSLabelItem {
                let label = UILabel()
                label.numberOfLines = 0
                label.lineBreakMode = .ByTruncatingTail
                label.textColor = styles.foregroundColor1
                label.font = styles.bodyFont
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
            else if let separatorItem = item as? SRSSeparatorItem {
                let separatorView = SRSSeparatorView()
                separatorView.applyStyles(styles)
                createdViews.append(separatorView)
            }
            
            // Filler Item
            else if let fillerItem = item as? SRSFillerItem {
                let fillerView = SRSFillerView()
                createdViews.append(fillerView)
            }
                
            // Item List
            else if let itemList = item as? SRSItemList {
                let itemListView = SRSItemListView()
                itemListView.contentInset = UIEdgeInsetsZero
                itemListView.applyStyles(styles)
                itemListView.itemList = itemList
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
