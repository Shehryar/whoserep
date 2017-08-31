//
//  CarouselViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CarouselViewItem: Component {
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case items
        case itemSpacing
        case visibleItemCount
        case pageControl
        case pagingEnabled
    }
    
    // MARK:- Defaults
    
    static let defaultItemSpacing: CGFloat = 8
    static let defaultVisibleItemCount: CGFloat = 1
    static let defaultPagingEnabled = false
    
    // MARK:- Properties
    
    let items: [Component]
    
    let itemSpacing: CGFloat
    
    let visibleItemCount: CGFloat
    
    let pagingEnabled: Bool
    
    let pageControlItem: PageControlItem?
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return CarouselView.self
    }
    
    override var nestedComponents: [Component]? {
        return items
    }
    
    // MARK:- Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        guard let content = content,
            let itemsJSON = content[JSONKey.items.rawValue] as? [[String : Any]] else {
                return nil
        }
        
        var items = [Component]()
        for itemJSON in itemsJSON {
            if let item = ComponentFactory.component(with: itemJSON, styles: styles) {
                items.append(item)
            }
        }
    
        guard items.count > 0 else {
            return nil
        }
            
        self.items = items
        self.itemSpacing = content.float(for: JSONKey.itemSpacing.rawValue)
            ?? CarouselViewItem.defaultItemSpacing
        self.visibleItemCount = content.float(for: JSONKey.visibleItemCount.rawValue)
            ?? CarouselViewItem.defaultVisibleItemCount
        self.pagingEnabled = content.bool(for: JSONKey.pagingEnabled.rawValue)
            ?? CarouselViewItem.defaultPagingEnabled
        if self.pagingEnabled {
            self.pageControlItem = ComponentFactory.component(with: content[JSONKey.pageControl.rawValue] as? [String : Any],
                                                              styles: styles) as? PageControlItem
        } else {
            self.pageControlItem = nil
        }
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }

}
