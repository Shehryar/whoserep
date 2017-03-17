//
//  ComponentFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- ComponentFactory

enum ComponentFactory {
    
    static func component(for type: ComponentType, with json: [String : AnyObject]?) -> Component? {
        guard let json = json else {
            return nil
        }
        
        switch type { // Maintain alphabetical order
        case .basicList: return BasicList.make(json)
        case .basicListItem: return BasicListItem.make(json)
        case .basicListSection: return BasicListSection.make(json)
        case .titleButtonContainer: return TitleButtonContainer.make(json)
        }
    }
    
    static func component(with json: [String : AnyObject]?) -> Component? {
        guard let json = json else {
            return nil
        }
        
        guard let typeString = json["template_type"] as? String else {
            DebugLog.w(caller: self, "Component json missing 'type': \(json)")
            return nil
        }
        
        guard let type = ComponentType(rawValue: typeString) else {
            DebugLog.w(caller: self, "Unknown Component Type [\(typeString)]: \(json)")
            return  nil
        }
        
        guard let content = json["content"] as? [String : AnyObject] else {
            DebugLog.w(caller: self, "Component missing content: \(json)")
            return nil
        }
        
        return component(for: type, with: content)
    }
}

// MARK:- Components [MAINTAIN ALPHABETICAL ORDER]

// MARK:- BasicList

extension BasicList: Component {
    
    var type: ComponentType {
        return .basicList
    }
    
    static func make(_ json: [String : AnyObject]) -> Component? {
        guard let sectionsJSONArray = json["sections"] as? [[String : AnyObject]] else {
            DebugLog.i(caller: self, "Missing sections. Returning nil.")
            return nil
        }
        
        var sections = [BasicListSection]()
        for sectionJSON in sectionsJSONArray {
            if let section = BasicListSection.make(sectionJSON) as? BasicListSection {
                sections.append(section)
            }
        }
        
        guard sections.count > 0 else {
            DebugLog.i(caller: self, "Empty sections. Returning nil.")
            return nil
        }
        
        var separatorStyle = SeparatorStyle.none
        if let separatorStyleString = json["separator_style"] as? String,
            let separatorStyleEnum = SeparatorStyle(rawValue: separatorStyleString) {
            separatorStyle = separatorStyleEnum
        }
        
        return BasicList(sections: sections, separatorStyle: separatorStyle)
    }
}

// MARK:- BasicListItem

extension BasicListItem: Component {
    
    var type: ComponentType {
        return .basicListItem
    }
    
    static func make(_ json: [String : AnyObject]) -> Component? {
        let title = json["title"] as? String
        let detail = json["detail"] as? String
        let value = json["value"] as? String
        let iconName = json["icon"] as? String
        
        // TODO: Icon factory -- don't show bad icons that we don't have on hand
        
        guard title != nil || detail != nil || value != nil else {
            DebugLog.w(caller: self, "Cannot create an empty item. Returning nil: \(json)")
            return nil
        }
        
        return BasicListItem(title: title, detail: detail, value: value, icon: iconName)
    }
}

// MARK:- BasicListSection

extension BasicListSection: Component {
    
    var type: ComponentType {
        return .basicListSection
    }
    
    static func make(_ json: [String : AnyObject]) -> Component? {
        guard let itemsJSON = json["items"] as? [[String : AnyObject]] else {
            DebugLog.w(caller: self, "Missing items. Returning nil.")
            return nil
        }
        
        var items = [BasicListItem]()
        for itemJSON in itemsJSON {
            if let item = BasicListItem.make(itemJSON) as? BasicListItem {
                items.append(item)
            }
        }
        
        guard !items.isEmpty else {
            DebugLog.w(caller: self, "Empty items. Returning nil.")
            return nil
        }
        
        let title = json["title"] as? String
        
        return BasicListSection(title: title, items: items)
    }
}

// MARK:- TitleButtonContainer

extension TitleButtonContainer: Component {
    
    var type: ComponentType {
        return .titleButtonContainer
    }
    
    static func make(_ json: [String : AnyObject]) -> Component? {
        guard let title = json["title"] as? String else {
            DebugLog.w(caller: self, "Missing title. Returning nil.")
            return nil
        }
        
        guard let contentJSON = json["content"] as? [String : AnyObject],
            let content = ComponentFactory.component(with: contentJSON) else {
                DebugLog.w(caller: self, "Missing content. Returning nil.")
                return nil
        }
        
        let button = SRSButtonItem.fromJSON(json["button"] as? [String : AnyObject])
        
        return TitleButtonContainer(title: title, button: button, content: content)
    }
}
