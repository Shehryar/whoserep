//
//  TableViewCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            componentView = component?.createView()
            componentView?.interactionHandler = interactionHandler
        }
    }
    
    var componentView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            if let componentView = componentView {
                contentView.addSubview(componentView.view)
                setNeedsLayout()
            }
        }
    }
    
    weak var interactionHandler: InteractionHandler? {
        didSet {
            componentView?.interactionHandler = interactionHandler
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        separatorInset = .zero
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    deinit {
         componentView?.interactionHandler = interactionHandler
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        componentView?.view.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let componentView = componentView else {
            return .zero
        }
        
        let margin = component?.style.margin ?? .zero
        var maxWidth = size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude
        maxWidth -= margin.left + margin.right
        
        var maxHeight = size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude
        maxHeight -= margin.top + margin.bottom
        
        guard maxWidth > 0 && maxHeight > 0 else {
            return .zero
        }
        
        var fittedSize = componentView.view.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
        fittedSize.width = ceil(fittedSize.width)
        fittedSize.height = ceil(fittedSize.height)
        return fittedSize
    }
}
