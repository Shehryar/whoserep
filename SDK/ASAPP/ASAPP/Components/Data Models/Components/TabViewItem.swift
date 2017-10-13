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
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        var pages = [TabViewPage]()
        if let pagesJSON = content?[JSONKey.pages.rawValue] as? [[String : Any]] {
            for pageJSON in pagesJSON {
                if let page = TabViewPage.init(json: pageJSON, styles: styles) {
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
    
    init?(json: Any?, styles: [String : Any]?) {
        guard let json = json as? [String : Any],
            let title = json[JSONKey.title.rawValue] as? String,
            let root = ComponentFactory.component(with: json[JSONKey.root.rawValue], styles: styles) else {
                return nil
        }
        self.title = title
        self.root = root
        super.init()
    }
}
