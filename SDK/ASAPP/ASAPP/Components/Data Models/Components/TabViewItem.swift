//
//  TabViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TabViewItem: Component {
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case pages
    }
    
    // MARK: - Properties
    
    let pages: [TabViewPage]
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return TabView.self
    }
    
    override var nestedComponents: [Component]? {
        var components = [Component]()
        for page in pages {
            components.append(page.root)
        }
        return components
    }
    
    // MARK: - Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        var pages = [TabViewPage]()
        if let dicts = Component.arrayOfDicts(content?[JSONKey.pages.rawValue]) {
            for dict in dicts {
                if let page = TabViewPage(dict: dict, styles: styles) {
                    pages.append(page)
                }
            }
        }
        guard pages.count > 0 else {
            DebugLog.w(caller: TableViewItem.self, "TabView missing pages. Returning nil for: \n\(String(describing: content))")
            return nil
        }
        self.pages = pages
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   isRequired: isRequired,
                   style: style,
                   styles: styles,
                   content: content)
    }
}

class TabViewPage: NSObject {
    
    enum JSONKey: String {
        case title
        case root
    }
    
    // MARK: Properties
    
    let title: String
    
    let root: Component
    
    // MARK: Init
    
    init?(dict: [String: Any], styles: [String: Any]?) {
        guard let title = dict[JSONKey.title.rawValue] as? String,
              let root = ComponentFactory.component(with: dict[JSONKey.root.rawValue], styles: styles) else {
            return nil
        }
        self.title = title
        self.root = root
        super.init()
    }
}
