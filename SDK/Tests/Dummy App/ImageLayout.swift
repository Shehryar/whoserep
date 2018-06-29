//
//  ImageLayout.swift
//  Tests
//
//  Created by Hans Hyttinen on 5/16/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class ImageLayout: ComponentViewController {
    let stackStyle: ComponentStyle = {
        var style = ComponentStyle()
        style.padding = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
        return style
    }()
    
    let itemStyle: ComponentStyle = {
        var style = ComponentStyle()
        style.margin = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        style.alignment = .fill
        return style
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = TestUtil.dictForFile(named: "image-layout")
        componentViewContainer = ComponentViewContainer.from(json)
        delegate = self
    }
}

extension ImageLayout: ComponentViewControllerDelegate {
    func componentViewController(_ viewController: ComponentViewController, didTapAPIAction action: APIAction, withFormData formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        return
    }
    
    func componentViewController(_ viewController: ComponentViewController, didTapHTTPAction action: HTTPAction, withFormData formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        return
    }
    
    func componentViewController(_ viewController: ComponentViewController, fetchContentForViewNamed viewName: String, withData data: [String: Any]?, completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        return
    }
    
    func componentViewControllerDidFinish(with action: FinishAction?, container: ComponentViewContainer?) {
        return
    }
}

extension ImageLayout: IdentifiableTestCase {
    static var testCaseIdentifier = "imageLayout"
}
