//
//  MultiChoiceOptionViewController.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/6/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol MultiChoiceDataSource {
    func availableAndSelectedChoices() -> [String: Bool]?
    func didFinishUpdatingChoices(choices: [String: Bool])
}

class MultiChoiceOptionViewController: UIViewController, MultiChoiceTopBarDelegate, UITableViewDelegate, UITableViewDataSource {

    var mContent: [String: Bool]!
    
    var topBar: MultiChoiceTopBar!
    var tableView: UITableView!
    
    var delegate: MultiChoiceDataSource!
    var mData: [String: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        setupBar()
        setupOptions()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setupBar() {
        topBar = MultiChoiceTopBar()
        topBar.delegate = self
        self.view.addSubview(topBar)
    }
    
    func setupOptions() {
        mData = delegate.availableAndSelectedChoices()!
        
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.registerClass(StepTableViewCell.self, forCellReuseIdentifier: "customCell")
        tableView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        tableView.separatorColor = UIColor.clearColor()
        
        self.view.addSubview(tableView)
    }
    
    func setContent(content: [String: Bool]) {
        self.mContent = content
        self.tableView.reloadData()
    }
    
    override func updateViewConstraints() {
        topBar.snp_remakeConstraints { (make) in
            make.top.equalTo(self.view.snp_top)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
        }
        
        tableView.snp_remakeConstraints { (make) in
            make.top.equalTo(topBar.snp_bottom)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(self.view.snp_bottom)
        }
        
        super.updateViewConstraints()
    }
    
    // MultiChoiceTopBarDelegate implementation
    func didCancelUpdatingChoices() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didFinishUpdatingChoices() {
        delegate.didFinishUpdatingChoices(mData)
        self.didCancelUpdatingChoices()
    }
    // End
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let options = mData
        return (options.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) as? StepTableViewCell
        
        let options = mData
        let index = options.startIndex.advancedBy(indexPath.row)
        
        cell?.setTitle((options.keys[index]), selected: (cell?.selected)!)
//        cell?.selectionStyle = .None
        if options[(options.keys[index])] == true {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = mData.startIndex.advancedBy(indexPath.row)
        mData[(mData.keys[index])] = true
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let index = mData.startIndex.advancedBy(indexPath.row)
        mData[(mData.keys[index])] = false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
