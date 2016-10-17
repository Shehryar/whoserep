//
//  ChatSuggestedReplyCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatSuggestedReplyCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    class func approximateHeight(withFont font: UIFont) -> CGFloat {
        return 20.0 /* insetTop */ + 20.0 /* insetBottom */ + ceil(font.lineHeight)
    }
    
    let imageSize: CGFloat = 13
    
    var separatorBottomColor: UIColor? {
        didSet {
            separatorBottomView.backgroundColor = separatorBottomColor
        }
    }
    
    var selectedBackgroundColor: UIColor? {
        didSet {
            if let selectedBackgroundColor = selectedBackgroundColor {
                customSelectedBackgroundView.backgroundColor = selectedBackgroundColor
                selectedBackgroundView = customSelectedBackgroundView
            } else {
                selectedBackgroundView = nil
            }
        }
    }
    
    var imageTintColor: UIColor = Colors.steelLightColor() {
        didSet {
            if imageTintColor != oldValue {
                updateImageView()
            }
        }
    }
    
    fileprivate let separatorBottomView = UIView()
    
    fileprivate let customSelectedBackgroundView = UIView()
    
    // MARK: Init
    
    func commonInit() {
        contentView.addSubview(separatorBottomView)
        
        textLabel?.textAlignment = .center
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .byTruncatingTail
        
        imageView?.contentMode = .scaleAspectFit
        updateImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: Layout
    
    func labelSizeThatFits(size: CGSize) -> CGSize {
        guard let textLabel = textLabel else { return CGSize.zero }
        
        let sideInset = contentInset.right + imageSize + 10
        let maxLabelWidth = size.width - 2 * sideInset
        let labelSize = textLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 0))
        
        return CGSize(width: maxLabelWidth, height: ceil(labelSize.height))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelSize = labelSizeThatFits(size: bounds.size)
        let labelLeft = floor((bounds.size.width - labelSize.width) / 2.0)
        let labelTop = floor((bounds.size.height - labelSize.height) / 2.0)
        textLabel?.frame = CGRect(x: labelLeft, y: labelTop, width: labelSize.width, height: labelSize.height)
        
        let imageLeft = bounds.size.width - contentInset.right - imageSize
        let imageTop = floor((bounds.size.height - imageSize) / 2.0)
        imageView?.frame = CGRect(x: imageLeft, y: imageTop, width: imageSize, height: imageSize)
        
        let separatorStroke: CGFloat = 1.0
        let separatorTop: CGFloat = bounds.height - separatorStroke
        separatorBottomView.frame = CGRect(x: 0.0, y: separatorTop, width: bounds.width, height: separatorStroke)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelSize = labelSizeThatFits(size: size)
        var contentHeight = labelSize.height
        if contentHeight > 0 {
            contentHeight += contentInset.top + contentInset.bottom
        }
        
        return CGSize(width: size.width, height: contentHeight)
    }
    
    // MARK: Selected / Highlighted
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        separatorBottomView.backgroundColor = separatorBottomColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        separatorBottomView.backgroundColor = separatorBottomColor
    }
    
    // MARK: Content
    
    func updateImageView() {
        imageView?.image = Images.iconExitLink(fillColor: imageTintColor)
    }
}
