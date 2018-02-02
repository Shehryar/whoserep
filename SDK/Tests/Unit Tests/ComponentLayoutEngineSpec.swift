//
//  ComponentLayoutEngineSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/21/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

// swiftlint:disable:next type_body_length
class ComponentLayoutEngineSpec: QuickSpec {
    override func spec() {
        describe("ComponentLayoutEngine") {
            let buttonHeight: CGFloat = 48
            let buttonWidth: CGFloat = 108
            
            describe(".getVerticalLayout(for:inside:)") {
                var style = ComponentStyle()
                var stackStyle: ComponentStyle!
                let width: CGFloat = 320
                let height: CGFloat = 700
                let bounds = CGRect(x: 0, y: 0, width: width, height: height)
                let content = [
                    "title": "Button",
                    "action": [
                        "type": "api",
                        "content": [
                            "requestPath": "foo"
                        ]
                    ]
                ] as [String: Any]
                
                beforeSuite {
                    ASAPP.styles.textStyles.button = ASAPPTextStyle(font: Fonts.default.bold, size: 13, letterSpacing: 1, color: UIColor.ASAPP.cometBlue, uppercase: true)
                    
                    style.alignment = .fill
                    
                    stackStyle = style
                    stackStyle.weight = 1
                    stackStyle.gravity = .fill
                    stackStyle.alignment = .fill
                    stackStyle.height = height
                    stackStyle.width = width
                }
                
                func getLayout(for styles: [ComponentStyle], in rect: CGRect? = nil) -> ComponentLayoutEngine.LayoutInfo {
                    let bounds = rect ?? bounds
                    var items = [Component]()
                    
                    for style in styles {
                        let button = ButtonItem(style: style, content: content)!
                        items.append(button)
                    }
                    
                    let stackItem = StackViewItem(orientation: .vertical, items: items, style: stackStyle)
                    let stackView = StackView(frame: bounds)
                    stackView.component = stackItem
                    return ComponentLayoutEngine.getVerticalLayout(for: stackView.nestedComponentViews as! [UIView], inside: bounds)
                }
                
                context("an empty layout") {
                    it("returns the expected layout info") {
                        let layoutInfo = ComponentLayoutEngine.getVerticalLayout(for: [], inside: bounds)
                        expect(layoutInfo.maxX).to(equal(0))
                        expect(layoutInfo.maxY).to(equal(0))
                        expect(layoutInfo.frames).to(beEmpty())
                    }
                }
                
                context("a non-component view") {
                    it("returns the expected layout info") {
                        let layoutInfo = ComponentLayoutEngine.getVerticalLayout(for: [UIView()], inside: bounds)
                        
                        expect(layoutInfo.maxX).to(equal(0))
                        expect(layoutInfo.maxY).to(equal(0))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: 0, height: 0)))
                    }
                }
                
                context("a trivial layout") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.gravity = .top
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                    }
                }
                
                context("one component with gravity: fill") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.gravity = .fill
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                    }
                }
                
                context("one component with gravity: fill and weight: 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.gravity = .fill
                        button1Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: height)))
                    }
                }
                
                context("one component with gravity: middle and weight: 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.gravity = .middle
                        button1Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height / 2 + floor(buttonHeight / 2)))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: height / 2 - ceil(buttonHeight / 2), width: width, height: buttonHeight)))
                    }
                }
                
                context("one component with gravity: top and weight: 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.gravity = .top
                        button1Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                    }
                }
                
                context("one component with gravity: bottom and weight: 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.gravity = .bottom
                        button1Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: height - buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("a non-component view and one component with gravity: top and weight: 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.gravity = .top
                        button1Style.weight = 1
                        let button1 = ButtonItem(style: button1Style, content: content)!
                        let stackItem = StackViewItem(orientation: .vertical, items: [button1], style: stackStyle)
                        let stackView = StackView(frame: bounds)
                        stackView.component = stackItem
                        let views = [UIView(), stackView.nestedComponentViews!.first!] as! [UIView]
                        let layoutInfo = ComponentLayoutEngine.getVerticalLayout(for: views, inside: bounds)
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames.count).to(equal(2))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: 0, height: 0)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                    }
                }
                
                context("a weighted layout") {
                    it("returns the expected layout info") {
                        let container = ComponentViewContainer.from(TestUtil.dictForFile(named: "feedback-form"))!
                        let root = container.createView()!
                        let layoutInfo = ComponentLayoutEngine.getVerticalLayout(for: root.view.subviews, inside: bounds)
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height))
                        expect(layoutInfo.frames.count).to(equal(2))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: height - buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: height - buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("two components with margins that are too big") {
                    it("returns the expected layout info") {
                        let height: CGFloat = 100
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: height / 2, left: 0, bottom: height / 2, right: 0)
                        
                        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
                        let layoutInfo = getLayout(for: [button1Style, style], in: bounds)
                        
                        expect(layoutInfo.maxX).to(equal(0))
                        expect(layoutInfo.maxY).to(equal(0))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: height / 2, width: 0, height: 0)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: height, width: 0, height: 0)))
                    }
                }
                
                context("two components with not enough space") {
                    it("returns the expected layout info") {
                        let height: CGFloat = buttonHeight - 10
                        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
                        let layoutInfo = getLayout(for: [style, style], in: bounds)
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: 0)))
                    }
                }
                
                context("two components in a weighted layout with not enough space") {
                    it("returns the expected layout info") {
                        let height: CGFloat = buttonHeight + 1
                        var button1Style = style
                        button1Style.weight = 0
                        var button2Style = style
                        button2Style.weight = 2
                        
                        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
                        let layoutInfo = getLayout(for: [button1Style, button2Style], in: bounds)
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: 0)))
                    }
                }
                
                context("two components with gravity: top") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                        button1Style.gravity = .top
                        var button2Style = style
                        button2Style.gravity = .top
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight * 2))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 1, y: 0, width: width - 1, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("two components with gravity: middle, one with alignment: right") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                        button1Style.gravity = .middle
                        var button2Style = style
                        button2Style.gravity = .middle
                        button2Style.alignment = .right
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight * 2))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 1, y: 0, width: width - 1, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: width - buttonWidth, y: buttonHeight, width: buttonWidth, height: buttonHeight)))
                    }
                }
                
                context("two components with gravity: bottom") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                        button1Style.gravity = .bottom
                        var button2Style = style
                        button2Style.gravity = .bottom
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight * 2))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 1, y: 0, width: width - 1, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("two components with gravity: fill") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                        button1Style.gravity = .fill
                        var button2Style = style
                        button2Style.gravity = .fill
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight * 2))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 1, y: 0, width: width - 1, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("two components with gravity: fill and weight: 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.weight = 1
                        var button2Style = style
                        button2Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: height / 2)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: height / 2, width: width, height: height / 2)))
                    }
                }
                
                context("two components with gravity: top and bottom") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                        button1Style.gravity = .top
                        var button2Style = style
                        button2Style.gravity = .bottom
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight * 2))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 1, y: 0, width: width - 1, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("two components with gravity: bottom and top") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                        button1Style.gravity = .bottom
                        var button2Style = style
                        button2Style.gravity = .top
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight * 2))
                        // using bottom and top to display items out of order is not supported
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 1, y: 0, width: width - 1, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("two components with weight: 0 and then 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.weight = 0
                        var button2Style = style
                        button2Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: height - buttonHeight)))
                    }
                }
                
                context("two components with weight: 1 and then 0") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.weight = 1
                        var button2Style = style
                        button2Style.weight = 0
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: height - buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: height - buttonHeight, width: width, height: buttonHeight)))
                    }
                }
                
                context("three components with weight: 0, 1, and 2 with a height that is not evenly divisible") {
                    it("returns the expected layout info") {
                        let height: CGFloat = 701
                        var button1Style = style
                        button1Style.weight = 0
                        var button2Style = style
                        button2Style.weight = 1
                        var button3Style = style
                        button3Style.weight = 2
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style, button3Style], in: CGRect(x: 0, y: 0, width: width, height: height))
                        let roundingErrorAdjustment: CGFloat = 2
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(height))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: 0, y: buttonHeight, width: width, height: floor((height - buttonHeight) / 3) + roundingErrorAdjustment)))
                        let frameHeight = floor((height - buttonHeight) / 3) * 2
                        expect(layoutInfo.frames[2]).to(equal(CGRect(x: 0, y: height - frameHeight, width: width, height: frameHeight)))
                    }
                }
            }
            
            describe(".getHorizontalLayout(for:inside:)") {
                var style = ComponentStyle()
                var stackStyle: ComponentStyle!
                let width: CGFloat = 700
                let height: CGFloat = 320
                let bounds = CGRect(x: 0, y: 0, width: width, height: height)
                let content = [
                    "title": "Button",
                    "action": [
                        "type": "api",
                        "content": [
                            "requestPath": "foo"
                        ]
                    ]
                ] as [String: Any]
                
                beforeSuite {
                    style.gravity = .fill
                    
                    stackStyle = style
                    stackStyle.weight = 1
                    stackStyle.gravity = .fill
                    stackStyle.alignment = .fill
                    stackStyle.height = height
                    stackStyle.width = width
                }
                
                func getLayout(for styles: [ComponentStyle], in rect: CGRect? = nil) -> ComponentLayoutEngine.LayoutInfo {
                    let bounds = rect ?? bounds
                    var items = [Component]()
                    
                    for style in styles {
                        let button = ButtonItem(style: style, content: content)!
                        items.append(button)
                    }
                    
                    let stackItem = StackViewItem(orientation: .horizontal, items: items, style: stackStyle)
                    let stackView = StackView(frame: bounds)
                    stackView.component = stackItem
                    return ComponentLayoutEngine.getHorizontalLayout(for: stackView.nestedComponentViews as! [UIView], inside: bounds)
                }
                
                context("an empty layout") {
                    it("returns the expected layout info") {
                        let layoutInfo = ComponentLayoutEngine.getHorizontalLayout(for: [], inside: bounds)
                        expect(layoutInfo.maxX).to(equal(0))
                        expect(layoutInfo.maxY).to(equal(0))
                        expect(layoutInfo.frames).to(beEmpty())
                    }
                }
                
                context("a non-component view") {
                    it("returns the expected layout info") {
                        let layoutInfo = ComponentLayoutEngine.getHorizontalLayout(for: [UIView()], inside: bounds)
                        
                        expect(layoutInfo.maxX).to(equal(0))
                        expect(layoutInfo.maxY).to(equal(0))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: 0, height: 0)))
                    }
                }
                
                context("a trivial layout") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.alignment = .left
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(buttonWidth))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)))
                    }
                }
                
                context("one component with alignment: fill") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.alignment = .fill
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(buttonWidth))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)))
                    }
                }
                
                context("one component with alignment: fill and weight: 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.alignment = .fill
                        button1Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames.count).to(equal(1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width, height: buttonHeight)))
                    }
                }
                
                context("two components with alignment: left and right") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
                        button1Style.alignment = .left
                        var button2Style = style
                        button2Style.alignment = .right
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(buttonWidth * 2))
                        expect(layoutInfo.maxY).to(equal(buttonHeight + 1))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 1, width: buttonWidth, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)))
                    }
                }
                
                context("two components with alignment: right and left") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.margin = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
                        button1Style.alignment = .right
                        var button2Style = style
                        button2Style.alignment = .left
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(buttonWidth * 2))
                        expect(layoutInfo.maxY).to(equal(buttonHeight + 1))
                        // using right and left to display items out of order is not supported
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 1, width: buttonWidth, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)))
                    }
                }
                
                context("two components with weight: 0 and then 1") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.weight = 0
                        var button2Style = style
                        button2Style.weight = 1
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: buttonWidth, y: 0, width: width - buttonWidth, height: buttonHeight)))
                    }
                }
                
                context("two components with weight: 1 and then 0") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.weight = 1
                        var button2Style = style
                        button2Style.weight = 0
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: width - buttonWidth, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: width - buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)))
                    }
                }
                
                context("three components with weight: 0, 1, and 2") {
                    it("returns the expected layout info") {
                        var button1Style = style
                        button1Style.weight = 0
                        var button2Style = style
                        button2Style.weight = 1
                        var button3Style = style
                        button3Style.weight = 2
                        
                        let layoutInfo = getLayout(for: [button1Style, button2Style, button3Style])
                        
                        expect(layoutInfo.maxX).to(equal(width))
                        expect(layoutInfo.maxY).to(equal(buttonHeight))
                        expect(layoutInfo.frames[0]).to(equal(CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)))
                        expect(layoutInfo.frames[1]).to(equal(CGRect(x: buttonWidth, y: 0, width: floor((width - buttonWidth) / 3), height: buttonHeight)))
                        let frameWidth = ceil((width - buttonWidth) / 3 * 2)
                        expect(layoutInfo.frames[2]).to(equal(CGRect(x: width - frameWidth, y: 0, width: frameWidth, height: buttonHeight)))
                    }
                }
            }
        }
    }
}
