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
        case cards = "cards"
        case cardSpacing = "cardSpacing"
        case cardDisplayCount = "cardDisplayCount"
        case pageControl = "pageControl"
        case pagingEnabled = "pagingEnabled"
        case quickReplies = "quickReplies"
    }
    
    // MARK:- Defaults
    
    static let defaultCardSpacing: CGFloat = 8
    static let defaultCardDisplayCount: CGFloat = 1
    static let defaultPagingEnabled = false
    
    // MARK:- Properties
    
    let cards: [Component]
    
    let cardSpacing: CGFloat
    
    let cardDisplayCount: CGFloat
    
    let pagingEnabled: Bool
    
    let pageControlItem: PageControlItem?
    
    let quickRepliesDictionary: [String : [SRSButtonItem]]?
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return CarouselView.self
    }
    
    override var nestedComponents: [Component]? {
        return cards
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        guard let content = content,
            let cardsJson = content[JSONKey.cards.rawValue] as? [[String : Any]] else {
                return nil
        }
        
        var cards = [Component]()
        for cardJson in cardsJson {
            if let card = ComponentFactory.component(with: cardJson, styles: styles) {
                cards.append(card)
            }
        }
    
        guard cards.count > 0 else {
            return nil
        }
    
        self.cards = cards
        self.cardSpacing = content.float(for: JSONKey.cardSpacing.rawValue)
            ?? CarouselViewItem.defaultCardSpacing
        self.cardDisplayCount = content.float(for: JSONKey.cardDisplayCount.rawValue)
            ?? CarouselViewItem.defaultCardDisplayCount
        self.pagingEnabled = content.bool(for: JSONKey.pagingEnabled.rawValue)
            ?? CarouselViewItem.defaultPagingEnabled
        if self.pagingEnabled {
            self.pageControlItem = ComponentFactory.component(with: content[JSONKey.pageControl.rawValue] as? [String : Any],
                                                              styles: styles) as? PageControlItem
        } else {
            self.pageControlItem = nil
        }
        
        
        if let quickRepliesJSONDict = content[JSONKey.quickReplies.rawValue] as? [String : [[String : Any]]] {
            var quickRepliesDictionary = [String : [SRSButtonItem]]()
            for (pageId, buttonsJSON) in quickRepliesJSONDict {
                var quickReplies = [SRSButtonItem]()
                for buttonJSON in buttonsJSON {
                    if let quickReply = SRSButtonItem.fromJSON(buttonJSON) {
                        quickReplies.append(quickReply)
                    }
                }
                if quickReplies.count > 0 {
                    quickRepliesDictionary[pageId] = quickReplies
                }
            }
            self.quickRepliesDictionary = quickRepliesDictionary
        } else {
            self.quickRepliesDictionary = nil
        }
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }

}
