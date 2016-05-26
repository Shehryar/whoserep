//
//  StepView.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 5/25/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class StepView: UIView, UITableViewDelegate, UITableViewDataSource {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    let titleView = UILabel()
    let contentView = UIView()
    
    var data: StepModel.Step!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(data: StepModel.Step) {
        self.init(frame: CGRectZero)
        self.setup()
        self.updateWithData(data)
    }
    
    func setup() {
        self.setupTitle()
        self.setupContent()
    }
    
    func updateWithData(data: StepModel.Step) {
        self.data = data
        self.renderTitle()
    }
    
    func setupTitle() {
        titleView.font = UIFont(name: "Lato-Bold", size: 22)
        titleView.textColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 0.95)
        self.addSubview(titleView)
        
        titleView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(60)
            make.leading.equalTo(self.snp_leading).offset(40)
            make.trailing.equalTo(self.snp_trailing).offset(40)
        }
    }
    
    func setupContent() {
        self.addSubview(contentView)
        
        contentView.snp_remakeConstraints { (make) in
            make.top.equalTo(titleView.snp_bottom)
            make.bottom.equalTo(self.snp_bottom)
            make.leading.equalTo(self.snp_leading).offset(40)
            make.trailing.equalTo(self.snp_trailing).offset(40)
        }
    }
    
    func renderTitle() {
        titleView.text = data.title
    }
    
    func renderContent() {
        if data.type == Type.MultiChoice {
            self.renderMultiChoiceContent()
        }
    }
    
    // Render Table View
    func renderMultiChoiceContent() {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        self.addSubview(tableView)
    }
    
    func getOptions() -> [String: Bool]? {
        if let content = data.content as? StepModel.StepTypeMultiChoice {
            return content.options
        }
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let options = self.getOptions()
        if options == nil {
            return 0
        }
        
        return (options!.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StepSummaryTableViewCell = tableView.dequeueReusableCellWithIdentifier("customSummaryCell") as! StepSummaryTableViewCell
        
        let options = self.getOptions()
        let index = options?.startIndex.advancedBy(indexPath.row)
        cell.setTitle((options?.keys[index!])!)
        
        return cell
    }
    
}
