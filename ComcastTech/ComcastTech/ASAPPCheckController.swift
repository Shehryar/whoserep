//
//  CheckViewController.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 5/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPCheckController: UIViewController {

    let holder = UIView()
    let nextButton = UIButton()
    
    var steps: [StepModel.Step] = []
    var stepView: StepView!
    
    var curStepIdx: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        setup()
    }
    
    func setup() {
        self.addStep("This is a test title", content: 1, continueText: "CONTINUE")
        self.addStep("This is a test title again", content: 1, continueText: "CONTINUE 2")
        
        setupNextStepButton()
        update()
        
        self.view.addSubview(self.stepView)
        self.view.addSubview(self.holder)
        self.holder.addSubview(self.nextButton)
    }
    
    func update() {
        if self.curStepIdx >= self.steps.count {
            return
        }
        updateStepView()
        updateNextStepButton()
    }
    
    func addStep(title: String, content: AnyObject, continueText: String) {
        let step = StepModel.Step(type: Type.Intro, title: title, content: content, continueText: continueText)
        self.steps.append(step)
    }
    
    func nextStep(sender: UIButton) {
        if self.curStepIdx >= self.steps.count - 1 {
            return
        }
        
        self.curStepIdx += 1
        self.update()
    }
    
    func previousStep() {
        if self.curStepIdx == 0 {
            return
        }
        
        self.curStepIdx -= 1
        self.update()
    }
    
    func updateStepView() {
        if self.stepView == nil {
            self.stepView = StepView(data: self.steps[self.curStepIdx])
        } else {
            self.stepView.updateWithData(self.steps[self.curStepIdx])
        }
    }
    
    func setupNextStepButton() {
        self.holder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
        
        self.nextButton.backgroundColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 0.95)
        self.nextButton.layer.cornerRadius = 5
        self.nextButton.clipsToBounds = true
        self.nextButton.titleLabel?.font = UIFont(name: "Lato-Black", size: 13)
        
        self.nextButton.addTarget(self, action: #selector(ASAPPCheckController.nextStep(_:)), forControlEvents: .TouchUpInside)
    }
    
    func updateNextStepButton() {
        let continueText = self.steps[self.curStepIdx].continueText
        let attributedString = NSMutableAttributedString(string: continueText)
        attributedString.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, continueText.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, continueText.characters.count))
        self.nextButton.setAttributedTitle(attributedString, forState: .Normal)
    }
    
    override func updateViewConstraints() {
        self.stepView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.view.snp_top).offset(0)
            make.width.equalTo(self.view.snp_width)
            make.centerX.equalTo(self.view.snp_centerX)
            make.bottom.equalTo(self.holder.snp_top)
        }
        
        self.holder.snp_remakeConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom)
            make.width.equalTo(self.view.snp_width)
            make.height.equalTo(132)
            make.centerX.equalTo(self.view.snp_centerX)
        }
        
        self.nextButton.snp_remakeConstraints { (make) in
            make.center.equalTo(holder.snp_center)
            make.width.equalTo(holder.snp_width).offset(-80)
            make.height.equalTo(60)
        }
        
        super.updateViewConstraints()
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
