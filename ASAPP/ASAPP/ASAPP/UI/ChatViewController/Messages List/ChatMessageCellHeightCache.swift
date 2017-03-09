//
//  ChatMessageCellHeightCache.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatMessageCellHeightCache: NSObject {

    fileprivate struct CachedHeight {
        let height: CGFloat
        let messagePosition: MessageListPosition
    }
    
    fileprivate var cache = [Event : CachedHeight]()
}

// MARK:- Public API

extension ChatMessageCellHeightCache {
    
    func getCachedHeight(event: Event, messagePosition: MessageListPosition) -> CGFloat? {
        if let cachedHeight = cache[event] {
            if cachedHeight.messagePosition == messagePosition {
                return cachedHeight.height
            }
        }
        return nil
    }
    
    func cacheHeight(_ height: CGFloat, for event: Event, messagePosition: MessageListPosition) {
        cache[event] = CachedHeight(height: height, messagePosition: messagePosition)
    }

    func clearCache() {
        cache.removeAll()
    }
}
