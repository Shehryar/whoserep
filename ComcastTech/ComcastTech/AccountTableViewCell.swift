//
//  AccountTableViewCell.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    var holder: UIView!
    var name: UILabel!
    var serviceLength: UILabel!
    var accountStatus: UILabel!
    var serviceHolder: UIView!
    
    var serviceOverviewLabel: UILabel!
    var serviceLengthLabel: UILabel!
    var accountStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render() {
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        
        let valueColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 1)
        let labelColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        
        holder = UIView()
        holder.backgroundColor = UIColor.whiteColor()
        holder.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).CGColor
        holder.layer.borderWidth = 1
        self.contentView.addSubview(holder)
        
        name = UILabel()
        name.lineBreakMode = NSLineBreakMode.ByWordWrapping
        name.numberOfLines = 0
        name.font = UIFont(name: "Lato-Bold", size: 22)
        name.textColor = valueColor
        holder.addSubview(name)
        
        serviceLength = UILabel()
        serviceLength.lineBreakMode = NSLineBreakMode.ByWordWrapping
        serviceLength.numberOfLines = 0
        serviceLength.font = UIFont(name: "Lato-Bold", size: 16)
        serviceLength.textColor = valueColor
        holder.addSubview(serviceLength)
        
        accountStatus = UILabel()
        accountStatus.lineBreakMode = NSLineBreakMode.ByWordWrapping
        accountStatus.numberOfLines = 0
        accountStatus.font = UIFont(name: "Lato-Bold", size: 16)
        accountStatus.textColor = valueColor
        holder.addSubview(accountStatus)
        
        serviceHolder = UIView()
        holder.addSubview(serviceHolder)
        
        // Fixed Labels
        
        serviceOverviewLabel = UILabel()
        serviceOverviewLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        serviceOverviewLabel.numberOfLines = 0
        serviceOverviewLabel.font = UIFont(name: "Lato-Regular", size: 11)
        serviceOverviewLabel.textColor = labelColor
        serviceOverviewLabel.text = "SERVICE OVERVIEW"
        holder.addSubview(serviceOverviewLabel)
        
        serviceLengthLabel = UILabel()
        serviceLengthLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        serviceLengthLabel.numberOfLines = 0
        serviceLengthLabel.font = UIFont(name: "Lato-Regular", size: 11)
        serviceLengthLabel.textColor = labelColor
        serviceLengthLabel.text = "LENGTH OF SERVICE"
        holder.addSubview(serviceLengthLabel)
        
        accountStatusLabel = UILabel()
        accountStatusLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        accountStatusLabel.numberOfLines = 0
        accountStatusLabel.font = UIFont(name: "Lato-Regular", size: 11)
        accountStatusLabel.textColor = labelColor
        accountStatusLabel.text = "ACCOUNT BILL STATUS"
        holder.addSubview(accountStatusLabel)
    }
    
    func updateAccount(account: TimelineModel.CCAccount?) {
        if account == nil {
            return
        }
        
        name.text = account!.Name
        serviceLength.text = account!.Length
        accountStatus.text = account!.Status
        addServices(account?.Services)
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
    
    func addServices(services: [CCServices]?) {
        if services == nil {
            return
        }
        
        var prevImageView: UIImageView? = nil
        for service in services! {
            var serviceIconName = "icon_timeline-"
            if service == .Internet {
                serviceIconName += "wifi"
            } else if service == .Video {
                serviceIconName += "tv"
            } else if service == .Phone {
                serviceIconName += "phone"
            } else if service == .Home {
                serviceIconName += "house"
            } else {
                continue
            }
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: serviceIconName)
            serviceHolder.addSubview(imageView)
            
            imageView.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(serviceHolder.snp_top)
                make.bottom.equalTo(serviceHolder.snp_bottom)
                make.trailing.lessThanOrEqualTo(serviceHolder.snp_trailing).priorityMedium()
                
                if prevImageView == nil {
                    make.leading.equalTo(serviceHolder.snp_leading)
                } else {
                    make.leading.equalTo((prevImageView?.snp_trailing)!).offset(5)
                }
            })
            
            prevImageView = imageView
        }
    }
    
    override func updateConstraints() {
        holder.snp_remakeConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top).offset(5)
            make.leading.equalTo(self.contentView.snp_leading).offset(10)
            make.trailing.equalTo(self.contentView.snp_trailing).offset(-10)
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-5).priorityMedium()
        }
        
        name.snp_remakeConstraints { (make) in
            make.top.equalTo(holder.snp_top).offset(20)
            make.leading.equalTo(holder.snp_leading).offset(20)
            make.width.equalTo(holder.snp_width).multipliedBy(0.5).offset(-30)
        }
        
        serviceOverviewLabel.snp_remakeConstraints { (make) in
            make.top.equalTo(name.snp_bottom).offset(20)
            make.leading.equalTo(name.snp_leading)
            make.trailing.equalTo(name.snp_trailing)
        }
        
        serviceHolder.snp_remakeConstraints { (make) in
            make.top.equalTo(serviceOverviewLabel.snp_bottom).offset(5)
            make.leading.equalTo(name.snp_leading)
            make.bottom.lessThanOrEqualTo(holder.snp_bottom).offset(-20).priorityMedium()
        }
        
        serviceLengthLabel.snp_remakeConstraints { (make) in
            make.top.equalTo(name.snp_top)
            make.leading.equalTo(name.snp_trailing).offset(10)
            make.trailing.equalTo(holder.snp_trailing).offset(-20)
        }
        
        serviceLength.snp_remakeConstraints { (make) in
            make.top.equalTo(serviceLengthLabel.snp_bottom).offset(5)
            make.leading.equalTo(serviceLengthLabel.snp_leading)
            make.trailing.equalTo(serviceLengthLabel.snp_trailing)
        }

        accountStatusLabel.snp_remakeConstraints { (make) in
            make.top.equalTo(serviceLength.snp_bottom).offset(20)
            make.leading.equalTo(serviceLengthLabel.snp_leading)
            make.trailing.equalTo(serviceLengthLabel.snp_trailing)
        }

        accountStatus.snp_remakeConstraints { (make) in
            make.top.equalTo(accountStatusLabel.snp_bottom).offset(5)
            make.leading.equalTo(accountStatusLabel.snp_leading)
            make.trailing.equalTo(accountStatusLabel.snp_trailing)
            make.bottom.lessThanOrEqualTo(holder.snp_bottom).offset(-20).priorityMedium()
        }
        
        super.updateConstraints()
    }

}
