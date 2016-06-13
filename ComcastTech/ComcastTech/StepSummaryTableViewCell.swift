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
    
    var button = UIButton()
    
    typealias Action = (() -> Void)
    var action: Action!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.contentView.addSubview(button)
//        self.contentView.addSubview(holder)
//        holder.addSubview(label)
        
        self.updateConstraints()
    }
    
    func setTitle(text: String) {
        let attributedString = NSMutableAttributedString(string: text.uppercaseString)
        attributedString.addAttribute(NSKernAttributeName, value: 1.5, range: NSMakeRange(0, text.characters.count))
        let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, text.characters.count))
        
        button.setAttributedTitle(attributedString, forState: .Normal)
    }
    
    func setNormalDisplay() {
//        holder.layer.borderColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1).CGColor
//        holder.layer.borderWidth = 1
//        holder.backgroundColor = UIColor.whiteColor()
//        
//        label.font = UIFont(name: "Lato-Black", size: 12)
//        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        label.textAlignment = .Center
        
        button.layer.borderColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1).CGColor
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.whiteColor()
        
        button.titleLabel!.font = UIFont(name: "Lato-Black", size: 12)
        button.titleLabel!.textAlignment = .Center
    }
    
    func setAddDisplay(onclick: Action) {
        button.layer.borderColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1).CGColor
        button.layer.borderWidth = 0
        button.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        
        button.titleLabel!.font = UIFont(name: "Lato-Black", size: 12)
        button.titleLabel!.textAlignment = .Center
        
        action = onclick
        button.addTarget(self, action: #selector(StepSummaryTableViewCell.buttonAction(_:)), forControlEvents: .TouchUpInside)
    }
    
    func buttonAction(sender: UIButton) {
        if action == nil {
            return
        }
        action()
    }
    
    override func updateConstraints() {
        button.snp_remakeConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top).offset(4)
            make.leading.equalTo(self.contentView.snp_leading).offset(0)
            make.trailing.equalTo(self.contentView.snp_trailing).offset(0)
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-4)
        }
        
//        label.snp_remakeConstraints { (make) in
//            make.center.equalTo(holder.center)
//            make.width.equalTo(holder.snp_width)
//            make.top.equalTo(holder.snp_top).offset(20)
//            make.bottom.equalTo(holder.snp_bottom).offset(-20)
//        }
        
        super.updateConstraints()
    }

}
