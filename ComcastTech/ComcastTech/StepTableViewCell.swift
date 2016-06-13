//
//  StepTableViewCell.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 5/25/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class StepTableViewCell: UITableViewCell {
    
    var label: UILabel!
    var mTitle: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected == true {
            self.contentView.backgroundColor = UIColor.whiteColor()
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
            self.backgroundColor = UIColor.clearColor()
        }
        
        // Looks hacky!!!
        if mTitle != nil {
            setTitle(mTitle, selected: selected)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        label = UILabel()
        label.font = UIFont(name: "Lato-Black", size: 12)
        label.textAlignment = .Center
        
        self.contentView.addSubview(label)
        self.updateConstraints()
    }
    
    func setTitle(text: String, selected: Bool) {
        var textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if selected == true {
            textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
        mTitle = text
        
        let attributedString = NSMutableAttributedString(string: mTitle.uppercaseString)
        attributedString.addAttribute(NSKernAttributeName, value: 1.5, range: NSMakeRange(0, mTitle.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, mTitle.characters.count))
        
        label.attributedText = attributedString
    }
    
    override func updateConstraints() {
        label.snp_remakeConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top)
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
        
        super.updateConstraints()
    }
}
