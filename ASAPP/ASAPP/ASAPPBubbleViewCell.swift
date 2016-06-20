//
//  ASAPPBubbleViewCell.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPBubbleViewCell: UITableViewCell {

    var holder: ASAPPBubbleView!
    var textMessageLabel: UILabel!
    
    let BUBBLE_PADDING: CGFloat = 16
    let HOLDER_PADDING: CGFloat = 16
    let HOLDER_PADDING_VERTICAL: CGFloat = 12
    
    var holderWidth: CGFloat = 0
    
    var mEvent: ASAPPEvent!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textMessageLabel = UILabel()
        setupLabel(textMessageLabel)
        
        holder = ASAPPBubbleView()
//        holder.clipsToBounds = true
        holder.backgroundColor = UIColor.clearColor()
        
        holder.addSubview(textMessageLabel)
        self.contentView.addSubview(holder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLabel(label: UILabel) {
        label.font = UIFont(name: "Lato-Regular", size: 16)
        label.textColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 0.6)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
    }
    
    func setEvent(event: ASAPPEvent) {
        if event.isMessageEvent() {
            if event.EventType == ASAPPEventType.EventTypeTextMessage {
                if let payload = event.payload() as? ASAPPEventPayload.TextMessage {
                    textMessageLabel.text = payload.Text
                }
            }
            
            drawBubble(event)
        }
        
        mEvent = event
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
    
    func drawBubble(event: ASAPPEvent) {
        let sendCorners: UIRectCorner = [UIRectCorner.TopRight, UIRectCorner.TopLeft, UIRectCorner.BottomLeft]
        let receiveCorners: UIRectCorner = [UIRectCorner.TopRight, UIRectCorner.TopLeft, UIRectCorner.BottomRight]
        var corners = sendCorners
        if !event.isCustomerEvent() {
            corners = receiveCorners
//            holder.backgroundColor = UIColor.redColor()
            holder.shouldShowBorder = true
        } else {
//            holder.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
            holder.shouldShowBorder = false
        }
        var borderRect = self.contentView.bounds
        if event.EventType == ASAPPEventType.EventTypeTextMessage {
            print("---------MMM - ", borderRect, UIScreen.mainScreen().bounds, self.bounds)
            let tempLabel = UILabel()
            setupLabel(tempLabel)
            if let payload = event.payload() as? ASAPPEventPayload.TextMessage {
                tempLabel.text = payload.Text
            }
            let size = tempLabel.sizeThatFits(CGSize(width: borderRect.size.width - ((BUBBLE_PADDING * 2) + (HOLDER_PADDING * 2)), height: CGFloat.max))
            holderWidth = size.width + (HOLDER_PADDING * 2)
            borderRect.size.width = size.width + (HOLDER_PADDING * 2)
            borderRect.size.height = size.height + (HOLDER_PADDING_VERTICAL * 2)
            print("---------", borderRect, tempLabel.text)
        }
//        borderRect.size.width = borderRect.size.width - (BUBBLE_PADDING * 2)
        let borderPath = UIBezierPath(roundedRect: borderRect, byRoundingCorners: corners, cornerRadii: CGSizeMake(20, 20))
        let borderLayer = CAShapeLayer()
        borderLayer.path = borderPath.CGPath
        holder.layer.mask = borderLayer
        
        holder.setNeedsDisplay()
    }
    
    override func updateConstraints() {
        print("=======", self.bounds)
        holder.snp_updateConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom)
            make.width.equalTo(holderWidth)
            
            if mEvent.isMessageEvent() {
                if mEvent.isCustomerEvent() {
                    make.leading.greaterThanOrEqualTo(self.contentView.snp_leading).offset(BUBBLE_PADDING)
                    make.trailing.equalTo(self.contentView.snp_trailing).offset(-BUBBLE_PADDING)
                } else {
                    make.leading.equalTo(self.contentView.snp_leading).offset(BUBBLE_PADDING)
                    make.trailing.lessThanOrEqualTo(self.contentView.snp_trailing).offset(-BUBBLE_PADDING)
                }
            }
        }
        
        textMessageLabel.snp_updateConstraints { (make) in
            make.top.equalTo(holder.snp_top).offset(HOLDER_PADDING_VERTICAL)
            make.leading.equalTo(holder.snp_leading).offset(HOLDER_PADDING)
            make.trailing.equalTo(holder.snp_trailing).offset(-HOLDER_PADDING)
            make.bottom.equalTo(holder.snp_bottom).offset(-HOLDER_PADDING_VERTICAL)
        }
        
        super.updateConstraints()
    }

}
