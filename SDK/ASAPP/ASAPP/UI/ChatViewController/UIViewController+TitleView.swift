//
//  UIViewController+TitleView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func createASAPPTitleView(title: String,
                              color: UIColor = ASAPP.styles.colors.navBarTitle,
                              padding: UIEdgeInsets = ASAPP.styles.navBarTitlePadding) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.setAttributedText(title, textType: .navTitle, color: color)
        let labelSize = label.sizeThatFits(CGSize.zero)
        
        let titleFrame = CGRect(x: 0, y: 0,
                                width: labelSize.width + padding.left + padding.right,
                                height: labelSize.height + padding.top + padding.bottom)
        let titleView = UIView(frame: titleFrame)
        
        label.frame = UIEdgeInsetsInsetRect(titleView.bounds, padding)
        titleView.addSubview(label)
        
        return titleView
    }
}