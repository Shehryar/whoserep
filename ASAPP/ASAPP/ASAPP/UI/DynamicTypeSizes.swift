//
//  DynamicTypeSizes.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class DynamicTypeUtility: NSObject {

    static var sizeTable: [UIFontTextStyle: [UIContentSizeCategory: Double]] = buildSizeTable()
    
    /**
     These are the sizes recommended by Apple:
     https://developer.apple.com/ios/human-interface-guidelines/visual-design/typography/
     */
    private class func buildSizeTable() -> [UIFontTextStyle: [UIContentSizeCategory: Double]] {
        var t: [UIFontTextStyle: [UIContentSizeCategory: Double]] = [
            .headline : [
                .extraSmall : 14,
                .small : 15,
                .medium : 16,
                .accessibilityMedium : 16,
                .large : 17,
                .accessibilityLarge : 17,
                .extraLarge : 19,
                .accessibilityExtraLarge : 19,
                .extraExtraLarge : 21,
                .accessibilityExtraExtraLarge : 21,
                .extraExtraExtraLarge : 23,
                .accessibilityExtraExtraExtraLarge : 23
            ],
            .subheadline : [
                .extraSmall : 12,
                .small : 13,
                .medium : 14,
                .accessibilityMedium : 14,
                .large : 15,
                .accessibilityLarge : 15,
                .extraLarge : 17,
                .accessibilityExtraLarge : 17,
                .extraExtraLarge : 19,
                .accessibilityExtraExtraLarge : 19,
                .extraExtraExtraLarge : 21,
                .accessibilityExtraExtraExtraLarge : 21
            ],
            .body : [
                .extraSmall : 14,
                .small : 15,
                .medium : 16,
                .accessibilityMedium : 16,
                .large : 17,
                .accessibilityLarge : 17,
                .extraLarge : 19,
                .accessibilityExtraLarge : 19,
                .extraExtraLarge : 21,
                .accessibilityExtraExtraLarge : 21,
                .extraExtraExtraLarge : 23,
                .accessibilityExtraExtraExtraLarge : 23
            ],
            .footnote : [
                .extraSmall : 12,
                .small : 12,
                .medium : 12,
                .accessibilityMedium : 12,
                .large : 13,
                .accessibilityLarge : 13,
                .extraLarge : 15,
                .accessibilityExtraLarge : 15,
                .extraExtraLarge : 17,
                .accessibilityExtraExtraLarge : 17,
                .extraExtraExtraLarge : 19,
                .accessibilityExtraExtraExtraLarge : 19
            ],
            .caption1 : [
                .extraSmall : 11,
                .small : 11,
                .medium : 11,
                .accessibilityMedium : 11,
                .large : 12,
                .accessibilityLarge : 12,
                .extraLarge : 14,
                .accessibilityExtraLarge : 14,
                .extraExtraLarge : 16,
                .accessibilityExtraExtraLarge : 16,
                .extraExtraExtraLarge : 18,
                .accessibilityExtraExtraExtraLarge : 18
            ],
            .caption2 : [
                .extraSmall : 11,
                .small : 11,
                .medium : 11,
                .accessibilityMedium : 11,
                .large : 11,
                .accessibilityLarge : 11,
                .extraLarge : 13,
                .accessibilityExtraLarge : 13,
                .extraExtraLarge : 15,
                .accessibilityExtraExtraLarge : 15,
                .extraExtraExtraLarge : 17,
                .accessibilityExtraExtraExtraLarge : 17
            ],
        ]
        
        if #available(iOS 9.0, *) {
            t[.title1] = [
                .extraSmall : 25,
                .small : 26,
                .medium : 27,
                .accessibilityMedium : 27,
                .large : 28,
                .accessibilityLarge : 28,
                .extraLarge : 30,
                .accessibilityExtraLarge : 30,
                .extraExtraLarge : 32,
                .accessibilityExtraExtraLarge : 32,
                .extraExtraExtraLarge : 34,
                .accessibilityExtraExtraExtraLarge : 34
            ]
            t[.title2] = [
                .extraSmall : 19,
                .small : 20,
                .medium : 21,
                .accessibilityMedium : 21,
                .large : 22,
                .accessibilityLarge : 22,
                .extraLarge : 24,
                .accessibilityExtraLarge : 24,
                .extraExtraLarge : 26,
                .accessibilityExtraExtraLarge : 26,
                .extraExtraExtraLarge : 28,
                .accessibilityExtraExtraExtraLarge : 28
            ]
            t[.title3] = [
                .extraSmall : 17,
                .small : 18,
                .medium : 19,
                .accessibilityMedium : 19,
                .large : 20,
                .accessibilityLarge : 20,
                .extraLarge : 22,
                .accessibilityExtraLarge : 22,
                .extraExtraLarge : 24,
                .accessibilityExtraExtraLarge : 24,
                .extraExtraExtraLarge : 26,
                .accessibilityExtraExtraExtraLarge : 26
            ]
            t[.callout] = [
                .extraSmall : 13,
                .small : 14,
                .medium : 15,
                .accessibilityMedium : 15,
                .large : 16,
                .accessibilityLarge : 16,
                .extraLarge : 18,
                .accessibilityExtraLarge : 18,
                .extraExtraLarge : 20,
                .accessibilityExtraExtraLarge : 20,
                .extraExtraExtraLarge : 22,
                .accessibilityExtraExtraExtraLarge : 22
            ]
        }
        
        return t
    }
    
}
