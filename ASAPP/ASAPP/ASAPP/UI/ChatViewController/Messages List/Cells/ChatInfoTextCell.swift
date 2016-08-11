//
//  ChatInfoTextCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatInfoTextCell: UITableViewCell, ASAPPStyleable {

    var infoText: String? {
        didSet {
            infoTextLabel.text = infoText
        }
    }
    
    // MARK: Properties
    
    private let contentInset = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
    
    private let textInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
    
    private let infoTextLabel = UILabel()
    
    private let textContainerView = UIView()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        opaque = true
        
        textContainerView.backgroundColor = Colors.lightGrayColor()
        contentView.addSubview(textContainerView)
        
        infoTextLabel.backgroundColor = textContainerView.backgroundColor
        infoTextLabel.textAlignment = .Center
        infoTextLabel.numberOfLines = 0
        infoTextLabel.textColor = Colors.mediumTextColor()
        infoTextLabel.font = Fonts.latoBoldFont(withSize: 14)
        textContainerView.addSubview(infoTextLabel)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
        textContainerView.backgroundColor = styles.backgroundColor2
        infoTextLabel.backgroundColor = textContainerView.backgroundColor
        infoTextLabel.textColor = styles.foregroundColor2
        infoTextLabel.font = styles.detailFont
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        
        textContainerView.snp_updateConstraints { (make) in
            make.centerX.equalTo(self.snp_centerX)
            make.width.lessThanOrEqualTo(self.snp_width).multipliedBy(0.6)
            make.top.equalTo(self.snp_top).offset(contentInset.top)
            make.height.equalTo(infoTextLabel.snp_height).offset(textInset.top + textInset.bottom)
        }
        
        infoTextLabel.snp_updateConstraints { (make) in
            make.top.equalTo(textContainerView.snp_top).offset(textInset.top)
            make.left.equalTo(textContainerView.snp_left).offset(textInset.left)
            make.width.equalTo(textContainerView.snp_width).offset(-(textInset.left + textInset.right))
            make.height.greaterThanOrEqualTo(1)
            make.bottom.equalTo(textContainerView.snp_bottom).offset(-textInset.bottom)
        }
        
        contentView.snp_updateConstraints { (make) in
            make.height.equalTo(textContainerView.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        
        super.updateConstraints()
    }
}
