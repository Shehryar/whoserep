//
//  ChatMessageCellHeightCache.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatMessageCellHeightCache: NSObject {

    private struct CachedHeight {
        let height: CGFloat
        let messagePosition: MessageListPosition
        let buttonsVisible: Bool
    }
    
    private var cache = [ChatMessage: CachedHeight]()
}

// MARK: - Public API

extension ChatMessageCellHeightCache {
    
    func getCachedHeight(for message: ChatMessage, with messagePosition: MessageListPosition, buttonsVisible: Bool) -> CGFloat? {
        if let cachedHeight = cache[message],
           cachedHeight.messagePosition == messagePosition
           && cachedHeight.buttonsVisible == buttonsVisible {
            return cachedHeight.height
        }
        return nil
    }
    
    func cacheHeight(_ height: CGFloat, for message: ChatMessage, with messagePosition: MessageListPosition, buttonsVisible: Bool) {
        cache[message] = CachedHeight(height: height, messagePosition: messagePosition, buttonsVisible: buttonsVisible)
    }

    func clearCache() {
        cache.removeAll()
    }
}
