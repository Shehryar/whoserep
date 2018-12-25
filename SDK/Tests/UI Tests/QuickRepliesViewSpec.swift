//
//  QuickRepliesViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/17/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class QuickRepliesViewSpec: QuickSpec {
    override func spec() {
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)
        let chatInputFrame = CGRect(x: 0, y: 730, width: 400, height: 70)
        
        let metadata: EventMetadata = {
            return EventMetadata(
                isReply: true,
                isAutomatedMessage: true,
                eventId: 0,
                eventType: .textMessage,
                issueId: 1,
                sendTime: Date(timeIntervalSince1970: 327511937))
        }()
        
        var exampleQuickReplies: [QuickReply] {
            return [
                QuickReply(title: "First", action: Action(content: "1")!, icon: nil, isTransient: false),
                QuickReply(title: "Second", action: Action(content: "2")!, icon: nil, isTransient: false),
                QuickReply(title: "Third", action: Action(content: "3")!, icon: nil, isTransient: false),
                QuickReply(title: "Fourth", action: Action(content: "4")!, icon: nil, isTransient: false),
                QuickReply(title: "Fifth", action: Action(content: "5")!, icon: nil, isTransient: false),
                QuickReply(title: "Sixth", action: Action(content: "6")!, icon: nil, isTransient: false)
            ]
        }
        
        func getExampleState(inputState: InputState? = nil) -> UIState {
            var state = UIState()
            state.animation = .withoutAnimation
            state.lastReply = ChatMessage(text: "Test message", attachment: nil, buttons: nil, quickReplies: exampleQuickReplies, metadata: metadata)
            if let inputState = inputState {
                state.queryUI.input = inputState
            }
            return state
        }
        
        func getView(for state: UIState) -> QuickRepliesView {
            let view = QuickRepliesView(frame: .zero)
            view.prepare(for: state, in: bounds)
            view.updateFrames(for: state.queryUI.input, in: bounds, with: chatInputFrame)
            return view
        }
        
        describe("QuickRepliesView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
            }
            
            context("on its own") {
                context("with default state") {
                    it("has a valid snapshot") {
                        let state = getExampleState()
                        let view = getView(for: state)
                        expect(view.bounds.height).to(equal(0))
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with prechat state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .prechat)
                        let view = getView(for: state)
                        expect(view.bounds.height).to(equal(0))
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with chatInput state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .chatInput(keyboardIsVisible: false))
                        let view = getView(for: state)
                        expect(view.bounds.height).to(equal(0))
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with chatInputWithQuickReplies state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .chatInputWithQuickReplies)
                        let view = getView(for: state)
                        expect(view.currentMessage?.metadata).to(equal(metadata))
                        expect(view).to(haveValidSnapshot())
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(311))
                    }
                }
                
                context("with quickRepliesAlone state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .quickRepliesAlone)
                        let view = getView(for: state)
                        expect(view).to(haveValidSnapshot())
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with quickRepliesWithNewQuestion state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .quickRepliesWithNewQuestion)
                        let view = getView(for: state)
                        expect(view).to(haveValidSnapshot())
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with newQuestionAlone state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .newQuestionAlone)
                        let view = getView(for: state)
                        expect(view).to(haveValidSnapshot())
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with newQuestionWithInset state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .newQuestionWithInset)
                        let view = getView(for: state)
                        expect(view).to(haveValidSnapshot())
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with newQuestionAloneLoading state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .newQuestionAloneLoading)
                        let view = getView(for: state)
                        expect(view).to(haveValidSnapshot())
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
                
                context("with inset state") {
                    it("has a valid snapshot") {
                        let state = getExampleState(inputState: .inset)
                        let view = getView(for: state)
                        expect(view.bounds.height).to(equal(0))
                        let fillHeight = view.sizeThatFills(bounds.size).height
                        expect(fillHeight).to(equal(241))
                    }
                }
            }
            
            context("with a previous state") {
                it("has a valid snapshot") {
                    for a in InputState.allCases {
                        for b in InputState.allCases {
                            let stateA = getExampleState(inputState: a)
                            let stateB = getExampleState(inputState: b)
                            let view = getView(for: stateA)
                            view.prepare(for: stateB, in: bounds)
                            view.updateFrames(for: stateB.queryUI.input, in: bounds, with: chatInputFrame)
                            if b.isEmpty {
                                expect(view.bounds.height).to(equal(0))
                            } else {
                                expect(view).to(haveValidSnapshot(named: nil, identifier: "\(a)-then-\(b)", usesDrawRect: true))
                            }
                        }
                    }
                }
            }
        }
    }
}
