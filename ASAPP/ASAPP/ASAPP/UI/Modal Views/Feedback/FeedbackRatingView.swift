//
//  FeedbackRatingView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class FeedbackRatingView: UIView {

    let contentInset = UIEdgeInsets.zero
    let starSpacing: CGFloat = 8.0
    
    var currentRating: Int? {
        didSet {
            
        }
    }
    
    var maxRating: Int {
        return starViews.count
    }
    
    let starViews: [StarView] = [StarView(), StarView(), StarView(), StarView(), StarView()]
    
    // MARK: Initialization
    
    func commonInit() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalWidth = bounds.size.width - contentInset.left - contentInset.right
        let numStars = CGFloat(starViews.count)
        let starWidth = (totalWidth - (numStars - 1) * starSpacing) / numStars
        let starHeight = bounds.height - contentInset.top - contentInset.bottom
        
        var contentLeft = contentInset.left
        for starView in starViews {
            starView.frame = CGRect(x: contentLeft, y: contentInset.top, width: starWidth, height: starHeight)
            contentLeft = starView.frame.maxX + starSpacing
        }
    }
}
