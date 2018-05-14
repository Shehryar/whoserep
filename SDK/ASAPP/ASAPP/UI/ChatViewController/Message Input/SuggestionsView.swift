//
//  SuggestionsView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/4/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol SuggestionsViewDelegate: class {
    func suggestionsView(_ suggestionsView: SuggestionsView, didSelectSuggestion suggestion: String, at index: Int, count: Int)
}

class SuggestionsView: UIView {
    weak var delegate: SuggestionsViewDelegate?
    
    var responseId: AutosuggestMetadata.ResponseId = ""
    
    private var suggestionButtons: [Button] = []
    private let blurredBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let topBorder = UIView()
    
    private let topBorderStroke: CGFloat = 1
    private let rowHeight: CGFloat = 33
    private let maxRows: Int = 3
    private let contentInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
    
    required init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        clipsToBounds = true
        
        addSubview(blurredBackground)
        
        topBorder.backgroundColor = ASAPP.styles.colors.separatorSecondary
        addSubview(topBorder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadWithSuggestions(_ suggestions: [String]) {
        for button in suggestionButtons {
            button.removeFromSuperview()
        }
        
        suggestionButtons = []
        
        for (i, suggestion) in suggestions.enumerated() {
            let button = Button()
            button.setBackgroundColor(.clear, forState: .normal)
            button.setBackgroundColor(ASAPP.styles.colors.primary, forState: .highlighted)
            button.setForegroundColor(ASAPP.styles.colors.dark, forState: .normal)
            button.setForegroundColor(.white, forState: .highlighted)
            button.label.updateFont(for: .body)
            button.label.adjustsFontSizeToFitWidth = false
            button.label.numberOfLines = 1
            button.contentAlignment = .left
            button.title = suggestion
            button.onTap = { [weak self] in
                self?.didSelectSuggestion(text: suggestion, index: i)
            }
            suggestionButtons.append(button)
            addSubview(button)
        }
    }
    
    func clear() {
        reloadWithSuggestions([])
    }
    
    @objc func didSelectSuggestion(text: String, index: Int) {
        delegate?.suggestionsView(self, didSelectSuggestion: text, at: index, count: suggestionButtons.count)
    }
}

// MARK: - Layout

extension SuggestionsView {
    private struct CalculatedLayout {
        let buttonFrames: [CGRect]
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        var buttonFrames: [CGRect] = []
        
        var totalHeight: CGFloat = topBorderStroke + contentInset.top
        for _ in suggestionButtons {
            let buttonFrame = CGRect(x: 0, y: totalHeight, width: bounds.width, height: rowHeight)
            buttonFrames.append(buttonFrame)
            totalHeight += rowHeight
        }
        
        return CalculatedLayout(buttonFrames: buttonFrames)
    }
    
    func updateFrames() {
        let layout = getFramesThatFit(bounds.size)
        for (button, frame) in zip(suggestionButtons, layout.buttonFrames) {
            button.frame = frame
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurredBackground.frame = bounds
        
        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: topBorderStroke)
        
        updateFrames()
        
        var visibleButtons: [Button] = []
        for button in suggestionButtons {
            if button.frame.maxY <= bounds.height {
                visibleButtons.append(button)
            } else {
                button.removeFromSuperview()
            }
        }
        suggestionButtons = visibleButtons
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        
        var totalHeight: CGFloat = 0
        let numRows = min(maxRows, layout.buttonFrames.count)
        for frame in layout.buttonFrames[0..<numRows] {
            totalHeight += frame.height
        }
        if totalHeight > 0 {
            totalHeight += topBorderStroke + contentInset.top + contentInset.bottom
        }
        
        return CGSize(width: size.width, height: totalHeight)
    }
}
