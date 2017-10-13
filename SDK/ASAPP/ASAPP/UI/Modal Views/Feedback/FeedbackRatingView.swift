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
    let starSpacing: CGFloat = 18.0
    
    private(set) var currentRating: Int?
    
    var maxRating: Int {
        return starViews.count
    }
    
    let starViews: [StarView] = [StarView(), StarView(), StarView(), StarView(), StarView()]
    
    // MARK: Initialization
    
    func commonInit() {
        for starView in starViews {
            addSubview(starView)
        }
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
    
    func getStarSizeThatFits(_ size: CGSize) -> CGSize {
        var starSize = size.width - contentInset.left - contentInset.right
        let numStars = CGFloat(starViews.count)
        if numStars > 1 {
            starSize -= (numStars - 1) * starSpacing
        } 
        starSize /= numStars
    
        if size.height > 0 {
            let maxStarHeight = size.height - contentInset.top - contentInset.bottom
            starSize = floor(min(starSize, maxStarHeight))
        }
        
        return CGSize(width: starSize, height: starSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let starSize = getStarSizeThatFits(size)
        let height = starSize.height + contentInset.top + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
    
    func updateFrames() {
        let starSize = getStarSizeThatFits(bounds.size)
        
        var contentLeft = contentInset.left
        for starView in starViews {
            guard starView.transform.isIdentity else {
                contentLeft += starSize.width + starSpacing
                continue
            }
            
            starView.frame = CGRect(x: contentLeft, y: contentInset.top,
                                    width: starSize.width, height: starSize.height)
            starView.updateFrames()
            contentLeft = starView.frame.maxX + starSpacing
        }
    }
}

// MARK: - Updating the rating

extension FeedbackRatingView {
    
    func setRating(_ rating: Int, animated: Bool) {
        guard rating != currentRating else {
            return
        }
        let oldRating = currentRating
        currentRating = rating
        
        for (idx, starView) in starViews.enumerated() {
            starView.isFilled = rating > idx
        }
        
        guard animated else {
            return
        }
        
        if oldRating == nil || rating > oldRating! {
            let starView = starViews[rating - 1]
            
            bringSubview(toFront: starView)
            
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 20,
                options: .beginFromCurrentState,
                animations: { 
                    starView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                }, completion: { _ in
                    UIView.animate(
                        withDuration: 0.25,
                        delay: 0,
                        options: [.beginFromCurrentState, .curveEaseOut],
                        animations: {
                            starView.transform = CGAffineTransform.identity
                    }, completion: { _ in
                        starView.updateFrames()
                    })
                })
        }
    }
}

// MARK: - Touches

extension FeedbackRatingView {

    func getRating(from location: CGPoint) -> Int {
        var rating = 1
        for starView in starViews where location.x > starView.frame.maxX {
            rating += 1
        }
        return min(rating, starViews.count)
    }
    
    func updateStarRating(for touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        let rating = getRating(from: location)
        
        setRating(rating, animated: true)
    }
    
    // MARK: Override
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateStarRating(for: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateStarRating(for: touches)
    }
}
