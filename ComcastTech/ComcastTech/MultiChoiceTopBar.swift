//
//  MultiChoiceTopBar.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/6/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol MultiChoiceTopBarDelegate {
    func didCancelUpdatingChoices()
    func didFinishUpdatingChoices()
}

class MultiChoiceTopBar: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var backButton: UIButton!
    var doneButton: UIButton!
    var searchField: UITextField!
    
    var delegate: MultiChoiceTopBarDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.backgroundColor = UIColor(red: 91/255, green: 101/255, blue: 126/255, alpha: 1)
        
        // NOTE: SnapKit should automatically set translatesAutoresizingMaskIntoConstraints = false, but it isn't.
        self.translatesAutoresizingMaskIntoConstraints = false
        setupBackButton()
        setupDoneButton()
        setupSearchBar()
    }
    
    func setupBackButton() {
        backButton = UIButton()
        backButton.setTitle("CANCEL", forState: .Normal)
        backButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.7), forState: .Normal)
        backButton.titleLabel?.font = UIFont(name: "Lato-Black", size: 12)
        
        backButton.addTarget(self, action: #selector(MultiChoiceTopBar.dismissView(_:)), forControlEvents: .TouchUpInside)
        
        self.addSubview(backButton)
    }
    
    func dismissView(sender: UIButton) {
        delegate.didCancelUpdatingChoices()
    }
    
    func setupDoneButton() {
        doneButton = UIButton()
        doneButton.setTitle("DONE", forState: .Normal)
        doneButton.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), forState: .Normal)
        doneButton.titleLabel?.font = UIFont(name: "Lato-Black", size: 12)
        
        doneButton.layer.cornerRadius = 4
        doneButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        doneButton.clipsToBounds = true
        
        doneButton.addTarget(self, action: #selector(MultiChoiceTopBar.saveAndDismissView(_:)), forControlEvents: .TouchUpInside)
        
        self.addSubview(doneButton)
    }
    
    func saveAndDismissView(sender: UIButton) {
        delegate.didFinishUpdatingChoices()
    }
    
    func setupSearchBar() {
        searchField = UITextField()
        searchField.backgroundColor = UIColor.whiteColor()
        searchField.layer.cornerRadius = 4
        searchField.clipsToBounds = true
        
        self.addSubview(searchField)
    }
    
    let ITEM_HEIGHT: Int = 40
    let BUTTON_WIDTH: Int = 80
    
    override func updateConstraints() {
        backButton.snp_remakeConstraints { (make) in
            make.leading.equalTo(self.snp_leading).offset(0)
            make.top.equalTo(self.snp_top).offset(22)
            make.bottom.equalTo(self.snp_bottom).offset(-8)
            make.width.equalTo(BUTTON_WIDTH)
        }
        
        doneButton.snp_remakeConstraints { (make) in
            make.trailing.equalTo(self.snp_trailing).offset(-8)
            make.top.equalTo(backButton.snp_top)
            make.bottom.equalTo(self.snp_bottom).offset(-8)
            make.height.equalTo(ITEM_HEIGHT)
            make.width.equalTo(backButton.snp_width)
        }
        
        searchField.snp_remakeConstraints { (make) in
            make.leading.equalTo(backButton.snp_trailing).offset(8)
            make.trailing.equalTo(doneButton.snp_leading).offset(-8)
            make.top.equalTo(doneButton.snp_top)
            make.bottom.equalTo(doneButton.snp_bottom)
        }
        
        super.updateConstraints()
    }
}
