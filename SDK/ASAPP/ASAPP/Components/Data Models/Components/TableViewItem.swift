//
//  TableViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TableViewItem: Component {

    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case sections
        case separatorStyle
    }
    
    // MARK: - Properties
    
    let sections: [TableViewSectionItem]
    
    let separatorStyle: UITableViewCellSeparatorStyle
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return TableView.self
    }
    
    override var nestedComponents: [Component]? {
        var nestedComponents = [Component]()
        for section in sections {
            nestedComponents.append(contentsOf: section.nestedComponents)
        }
        return nestedComponents
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
        var sections = [TableViewSectionItem]()
        if let dicts = Component.arrayOfDicts(content?[JSONKey.sections.rawValue]) {
            for dict in dicts {
                if let section = TableViewSectionItem(dict: dict, styles: styles) {
                    sections.append(section)
                }
            }
        }
        guard sections.count > 0 else {
            DebugLog.w(caller: TableViewItem.self, "Empty table view sections. Returning nil for: \n\(String(describing: content))")
            return nil
        }
        self.sections = sections
        
        var separatorStyle: UITableViewCellSeparatorStyle = .singleLine
        if let separatorStyleValue = content?[JSONKey.separatorStyle.rawValue] as? String,
            separatorStyleValue != "singleLine" {
            separatorStyle = .none
        }
        self.separatorStyle = separatorStyle
        
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

class TableViewSectionItem: NSObject {
    
    enum JSONKey: String {
        case header
        case rows
    }
    
    var nestedComponents: [Component] {
        var nestedComponents = [Component]()
        if let header = header {
            nestedComponents.append(header)
        }
        nestedComponents.append(contentsOf: rows)
        return nestedComponents
    }
    
    let header: Component?
    
    let rows: [Component]
    
    init?(dict: [String: Any], styles: [String: Any]?) {
        self.header = ComponentFactory.component(with: dict[JSONKey.header.rawValue], styles: styles)
        var rows = [Component]()
        if let rowDicts = Component.arrayOfDicts(dict[JSONKey.rows.rawValue]) {
            for rowDict in rowDicts {
                if let row = ComponentFactory.component(with: rowDict, styles: styles) {
                    rows.append(row)
                }
            }
        }
        self.rows = rows
        
        super.init()
    }
}
