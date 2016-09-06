//
//  SummaryDetailsView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/18/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SummaryDetailsView: UIView, ASAPPStyleable {

    // MARK: Properties
    
    private let containerStackView = StackView()
    
    private let headerContainer = StackView()
    private let subheaderLabel = UILabel()
    private let headerLabel = UILabel()
    private let headerDetailLabel = UILabel()
    
    private let detailsContainer = StackView()
    
    private let buttonsContainer = StackView()
    private let button1 = Button()
    private let button2 = Button()

    // MARK: Initialization
    
    func commonInit() {
        
        subheaderLabel.numberOfLines = 0
        subheaderLabel.lineBreakMode = .ByTruncatingTail
        subheaderLabel.text = "Current Balance"
        
        headerLabel.text = "$135.43*"
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .ByTruncatingTail
        
        headerDetailLabel.text = "Auto Pay scheduled for 09/01/16"
        headerDetailLabel.numberOfLines = 0
        headerDetailLabel.lineBreakMode = .ByTruncatingTail
        headerContainer.viewSpacing = 4
        headerContainer.contentInset = UIEdgeInsetsZero
        headerContainer.addArrangedViews([subheaderLabel, headerLabel, headerDetailLabel])
        
        detailsContainer.viewSpacing = 2.0
        detailsContainer.addArrangedViews([
            TwoColumnLabelView(leftText: "Line Item 1", rightText: "49.99"),
            TwoColumnLabelView(leftText: "Line Item 2", rightText: "20.00"),
            TwoColumnLabelView(leftText: "Line Item 3", rightText: "30.00"),
            TwoColumnLabelView(leftText: "Line Item 4", rightText: "35.44"),
            TwoColumnLabelView(leftText: "Total:", rightText: "$135.43")
            ])
        detailsContainer.contentInset = UIEdgeInsetsZero
    
        button1.title = "View Full Statement"
        button1.font = Fonts.latoBoldFont(withSize: 14)
        button1.backgroundColor = Colors.blueColor()
        button1.foregroundColor = Colors.whiteColor()
        button2.title = "Make a Payment"
        button2.font = Fonts.latoBoldFont(withSize: 14)
        button2.backgroundColor = Colors.blueColor()
        button2.foregroundColor = Colors.whiteColor()
        buttonsContainer.contentInset = UIEdgeInsetsZero
        buttonsContainer.viewSpacing = 8.0
        buttonsContainer.addArrangedViews([button1, button2])
        
        containerStackView.addArrangedViews([headerContainer, detailsContainer, buttonsContainer])
        addSubview(containerStackView)
        
        applyStyles(styles)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // View:- View Creation
    
    
    // MARK:- ASAPPStyleable
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
        layer.borderColor = styles.separatorColor1.CGColor
        layer.borderWidth = 1.0
        
        subheaderLabel.font = styles.captionFont
        subheaderLabel.textColor = styles.foregroundColor1
        
        headerLabel.font = styles.headlineFont
        headerLabel.textColor = styles.foregroundColor1
        
        headerDetailLabel.font = styles.detailFont
        headerDetailLabel.textColor = styles.foregroundColor2
        
        for labelPair in detailsContainer.arrangedSubviews {
            if let labelPair = labelPair as? TwoColumnLabelView {
                labelPair.leftLabel.font = styles.detailFont
                labelPair.leftLabel.textColor = styles.foregroundColor2
                
                labelPair.rightLabel.font = styles.detailFont
                labelPair.rightLabel.textColor = styles.foregroundColor1
            }
        }
        
        for button in buttonsContainer.arrangedSubviews {
            if let button = button as? Button {
                button.backgroundColor = styles.backgroundColor1
                button.font = styles.buttonFont
                button.layer.borderWidth = 1.0
                button.layer.borderColor = styles.separatorColor1.CGColor
                button.foregroundColor = styles.foregroundColor1
            }
        }
    }
    
    // MARK:- Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerStackView.frame = bounds
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return containerStackView.sizeThatFits(size)
    }
}
