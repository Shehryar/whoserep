//
//  StepSummaryTableViewCell.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 5/25/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class StepSummaryTableViewCell: UITableViewCell {

    var holder = UIView()
    var label = UILabel()
    
    var mTitle: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setup()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        holder.layer.borderColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1).CGColor
        holder.layer.borderWidth = 1
        self.addSubview(holder)
        
        label.font = UIFont(name: "Lato-Black", size: 13)
        holder.addSubview(label)
    }
    
    func setTitle(text: String) {
        self.mTitle = text
        
        let attributedString = NSMutableAttributedString(string: text.uppercaseString)
        attributedString.addAttribute(NSKernAttributeName, value: 1.5, range: NSMakeRange(0, text.characters.count))
        let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, text.characters.count))
        
        self.label.attributedText = attributedString
    }
    
    override func updateConstraints() {
        holder.snp_remakeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(4)
            make.leading.equalTo(self.snp_leading).offset(40)
            make.trailing.equalTo(self.snp_trailing).offset(40)
            make.height.equalTo(58)
            make.bottom.equalTo(self.snp_bottom).offset(4)
        }
        
        label.snp_remakeConstraints { (make) in
            make.center.equalTo(holder.center)
            make.width.equalTo(holder.snp_width).offset(-60)
        }
    }

}
