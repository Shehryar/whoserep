//
//  SingleComponentViewController.swift
//  Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class SingleComponentViewController: ComponentViewController {
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
    
    var component: Component {
        return ButtonItem(style: itemStyle)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let root = StackViewItem(orientation: .vertical, items: [component], style: stackStyle)!
        componentViewContainer = ComponentViewContainer(root: root, title: "Title", styles: nil)
    }
}
