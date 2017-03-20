//
//  ProgressBarItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ProgressBarItem: NSObject, Component {
    
    // MARK: Defaults
    
    static let defaultFillColor = UIColor(red:0.447, green:0.788, blue:0.384, alpha:1.000)
    
    static let defaultContainerColor = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
    
    static let defaultBarHeight: CGFloat = 10.0

    // MARK: Properties
    
    let fillPercentage: CGFloat /* 0...1 */
    
    let fillColor: UIColor
    
    let containerColor: UIColor
    
    let barHeight: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.progressBar
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(fillPercentage: CGFloat,
         fillColor: UIColor?,
         containerColor: UIColor?,
         barHeight: CGFloat?,
         id: String?,
         layout: ComponentLayout) {
        self.fillPercentage = fillPercentage
        self.fillColor = fillColor ?? ProgressBarItem.defaultFillColor
        self.containerColor = containerColor ?? ProgressBarItem.defaultContainerColor
        self.barHeight = barHeight ?? ProgressBarItem.defaultBarHeight
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        
        let fillPercentage = content.float(for: "fill_percentage", defaultValue: 0)
        let fillColor = content.hexColor(for: "fill_color")
        let containerColor = content.hexColor(for: "container_color")
        let barHeight = content.float(for: "bar_height")
        
        return ProgressBarItem(fillPercentage: fillPercentage,
                               fillColor: fillColor,
                               containerColor: containerColor,
                               barHeight: barHeight,
                               id: id,
                               layout: layout)
    }
}
