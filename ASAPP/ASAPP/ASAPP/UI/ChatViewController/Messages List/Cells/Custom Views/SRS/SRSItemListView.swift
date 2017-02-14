//
//  SRSItemListView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol SRSItemListViewDelegate: class {
    func itemListView(_ itemListView: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem)
}

class SRSItemListView: StackView, ASAPPStyleable {
    
    weak var delegate: SRSItemListViewDelegate?
    
    private var contentItems: [AnyObject]?
    private var inlineButtonItems: [SRSButtonItem]?
    
    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        setNeedsLayout()
    }
    
    // MARK: Content
    
    func setContentItems(_ contentItems: [AnyObject]?, inlineButtonItems: [SRSButtonItem]? = nil) {
        self.contentItems = contentItems
        self.inlineButtonItems = inlineButtonItems
        
        reloadSubviews()
    }
    
    // MARK: Creating the Views
    
    private func reloadSubviews() {
        clear()

        var createdViews = [UIView]()
        
        if let contentItems = contentItems {
            for item in contentItems {
             
                // Label Item
                if let labelItem = item as? SRSLabelItem {
                    let label = UILabel()
                    label.numberOfLines = 0
                    label.lineBreakMode = .byTruncatingTail
                    label.textColor = styles.foregroundColor2
                    label.textAlignment = .center
                    label.text = labelItem.text
                    label.setAttributedText(labelItem.text,
                                            textStyle: .srsLabel,
                                            color: styles.foregroundColor2,
                                            styles: styles)
                    
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
                    
                // Image Item
                else if let imageItem = item as? SRSImageItem {
                    let imageItemView = SRSImageItemView()
                    imageItemView.applyStyles(styles)
                    imageItemView.imageItem = imageItem
                    createdViews.append(imageItemView)
                }
                    
                // Map Item
                else if let mapItem = item as? SRSMapItem {
                    let mapItemView = SRSMapItemView()
                    mapItemView.applyStyles(styles)
                    mapItemView.mapItem = mapItem
                    createdViews.append(mapItemView)
                }
                    
                // Icon
                else if let iconItem = item as? SRSIconItem {
                    let iconItemView = SRSIconItemView()
                    iconItemView.applyStyles(styles)
                    iconItemView.iconItem = iconItem
                    createdViews.append(iconItemView)
                }
                    
                // Item List
                else if let itemList = item as? SRSItemList {
                    let itemListView = SRSItemListView()
                    itemListView.contentInset = UIEdgeInsets.zero
                    itemListView.applyStyles(styles)
                    itemListView.setContentItems(itemList.items)
                    if itemList.orientation == .Vertical {
                        itemListView.orientation = .vertical
                    } else {
                        itemListView.orientation = .horizontal
                    }
                    createdViews.append(itemListView)
                }
            }
        }
        
        if let inlineButtonItems = inlineButtonItems {
            if inlineButtonItems.count > 0 {
                
            }
        }
        
        addArrangedViews(createdViews)
    }
}
