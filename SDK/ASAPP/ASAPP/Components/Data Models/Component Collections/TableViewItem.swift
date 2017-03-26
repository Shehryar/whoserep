//
//  TableViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TableViewItem: Component {

    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case sections = "sections"
    }
    
    // MARK:- Properties
    
    let sections: [TableViewSectionItem]
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return TableView.self
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        var sections = [TableViewSectionItem]()
        if let sectionsJSON = content?[JSONKey.sections.rawValue] as? [[String : Any]] {
            for sectionJSON in sectionsJSON {
                if let section = TableViewSectionItem(json: sectionJSON, styles: styles) {
                    sections.append(section)
                }
            }
        }
        guard sections.count > 0 else {
            DebugLog.w(caller: TableViewItem.self, "Empty table view sections. Returning nil for: \n\(content)")
            return nil
        }
        self.sections = sections
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
    
}


class TableViewSectionItem: NSObject {
    
    enum JSONKey: String {
        case header = "header"
        case rows = "rows"
    }
    
    let header: Component?
    
    let rows: [Component]
    
    init?(json: Any?, styles: [String : Any]?) {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        self.header = ComponentFactory.component(with: json[JSONKey.header.rawValue], styles: styles)
        var rows = [Component]()
        if let rowsJSON = json[JSONKey.rows.rawValue] as? [[String : Any]] {
            for rowJSON in rowsJSON {
                if let row = ComponentFactory.component(with: rowJSON, styles: styles) {
                    rows.append(row)
                }
            }
        }
        self.rows = rows
        
        super.init()
    }
}
