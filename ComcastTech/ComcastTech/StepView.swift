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
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupTitle()
        self.setupContent()
    }
    
    func updateWithData(data: StepModel.Step) {
        self.data = data
        self.renderTitle()
        self.renderContent()
    }
    
    func setupTitle() {
        titleView.font = UIFont(name: "Lato-Bold", size: 22)
        titleView.textColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 0.95)
        self.addSubview(titleView)
    }
    
    func setupContent() {
        self.addSubview(contentView)
        contentView.backgroundColor = UIColor.grayColor()
    }
    
    override func updateConstraints() {
        titleView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(40)
            make.width.equalTo(self.snp_width).offset(-80)
            make.centerX.equalTo(self.snp_centerX)
        }
        
        contentView.snp_remakeConstraints { (make) in
            make.top.equalTo(titleView.snp_bottom).offset(20)
            make.bottom.equalTo(self.snp_bottom)
            make.leading.equalTo(titleView.snp_leading)
            make.trailing.equalTo(titleView.snp_trailing)
        }
        
        super.updateConstraints()
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
    let SUMMARY_CELL_IDENTIFIER = "customSummaryCell"
    
    func renderMultiChoiceContent() {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(StepSummaryTableViewCell.self, forCellReuseIdentifier: SUMMARY_CELL_IDENTIFIER)
        tableView.separatorColor = UIColor.clearColor()
        tableView.allowsSelection = false
        tableView.bounces = false
        
        self.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) in
            make.center.equalTo(self.contentView.snp_center)
            make.size.equalTo(self.contentView.snp_size)
        }
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
        print(options?.count)
        return (options?.count)! + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SUMMARY_CELL_IDENTIFIER, forIndexPath: indexPath) as? StepSummaryTableViewCell
        
        let options = self.getOptions()
        let index = options?.startIndex.advancedBy(indexPath.row)
        
        if indexPath.row < tableView.numberOfRowsInSection(indexPath.section) - 1 {
            cell!.setTitle((options?.keys[index!])!)
            cell?.setNormalDisplay()
        } else {
            cell?.setTitle("Add More")
            cell?.setAddDisplay()
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
}
