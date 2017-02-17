//
//  SRSItemListContentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSItemListContentView: StackView, ASAPPStyleable {

    var contentItems: [AnyObject]? {
        didSet {
            reloadSubviews()
        }
    }

    
    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        setNeedsLayout()
    }
    
    // MARK: Creating the Views
    
    private func reloadSubviews() {
        clear()

        var createdViews = [UIView]()
        
        if let contentItems = contentItems {
            for item in contentItems {
             
                // Icon
                if let iconItem = item as? SRSIconItem {
                    let iconItemView = SRSIconItemView()
                    iconItemView.applyStyles(styles)
                    iconItemView.iconItem = iconItem
                    createdViews.append(iconItemView)
                }
                
                // Label Item
                if let labelItem = item as? SRSLabelItem {
                    let labelItemView = SRSLabelItemView()
                    labelItemView.applyStyles(styles)
                    labelItemView.labelItem = labelItem
                    createdViews.append(labelItemView)
                }
                    
                // Label Value Item
                else if let labelValueItem = item as? SRSLabelValueItem {
                    let labelValueItemView: SRSLabelValueItemView
                    switch labelValueItem.type {
                    case .horizontal:
                        labelValueItemView = SRSLabelValueHorizontalItemView()
                        break
                        
                    case .vertical:
                        labelValueItemView = SRSLabelValueVerticalItemView()
                        break
                    }
                    
                    labelValueItemView.applyStyles(styles)
                    labelValueItemView.labelValueItem = labelValueItem
                    createdViews.append(labelValueItemView)
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
            }
        }

        addArrangedViews(createdViews)
    }
}
