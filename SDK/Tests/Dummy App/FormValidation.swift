//
//  FormValidation.swift
//  Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class FormValidation: ComponentViewController {
    let stackStyle: ComponentStyle = {
        var s = ComponentStyle()
        s.padding = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
        return s
    }()
    
    let itemStyle: ComponentStyle = {
        var s = ComponentStyle()
        s.margin = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        s.alignment = .fill
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = TestUtil.dictForFile(named: "change-pin-form-proper-padding")
        componentViewContainer = ComponentViewContainer.from(json)
        delegate = self
    }
}

extension FormValidation: ComponentViewControllerDelegate {
    func componentViewController(_ viewController: ComponentViewController, didTapAPIAction action: APIAction, withFormData formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        return
    }
    
    func componentViewController(_ viewController: ComponentViewController, didTapHTTPAction action: HTTPAction, withFormData formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        return
    }
    
    func componentViewController(_ viewController: ComponentViewController, fetchContentForViewNamed viewName: String, withData data: [String: Any]?, completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        return
    }
    
    func componentViewControllerDidFinish(with action: FinishAction?) {
        return
    }
}

extension FormValidation: IdentifiableTestCase {
    static var testCaseIdentifier = "formValidation"
}
