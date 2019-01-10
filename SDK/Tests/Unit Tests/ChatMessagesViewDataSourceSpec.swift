//
//  ChatMessagesViewDataSourceSpec.swift
//  Unit Tests
//
//  Created by Shehryar Hussain on 12/26/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ChatMessagesViewDataSourceSpec: QuickSpec {
    
    var events: [Event] {
        let eventList = TestUtil.dictForFile(named: "event-list-long")
        let incomingMessages = IncomingMessage()
        incomingMessages.body = eventList!
        incomingMessages.type = .response
        let parsedEvents = incomingMessages.parseEvents()
        return parsedEvents.events!
    }
    
    override func spec() {
        var dataSource = ChatMessagesViewDataSource()
        
        func loadData() {
            dataSource.reloadWithEvents(events)
        }
        func loadMore() {
            let messages = events.map { $0.chatMessage }.compactMap { $0 }
            dataSource.insertMessages(Array(messages))
        }
        
        describe("ChatMessagesViewDataSource") {
            context("data source loaded data when it was empty") {
                beforeEach {
                    loadData()
                }
                it("has n sections") {
                    expect(dataSource.numberOfSections()).to(equal(3))
                }
                
                it("gets the correct last index path") {
                    let lastIndexPath = IndexPath(row: 0, section: 2)
                    expect(dataSource.getLastIndexPath()).to(equal(lastIndexPath))
                }
                
                it("has n rows in n section") {
                    expect(dataSource.numberOfRowsInSection(2)).to(equal(1))
                }
                
                it("has a last reply") {
                    expect(dataSource.getLastReply()).toNot(beNil())
                }
                
                it("gets the proper header time") {
                    expect(dataSource.getHeaderTime(for: 2)).toNot(beNil())
                    let date = Date(iso8601DateString: "2018-12-20")
                    expect(dataSource.getHeaderTime(for: 1)?.asISO8601DateString).to(equal(date?.asISO8601DateString))
                }
                
                it("gets the first of recent replies") {
                    expect(dataSource.getFirstOfRecentReplies()).toNot(beNil())
                    expect(dataSource.isEmpty()).to(beFalse())
                }
            }
            
            context("data source has messages already and then adds more") {
                beforeEach {
                    loadData()
                    loadMore()
                }
                it("should load more messages") {
                    expect(dataSource.allMessages).toNot(beNil())
                    let new = dataSource.getLastMessage()
                    let updated = dataSource.updateMessage(new!)
                    expect(updated).toNot(beNil())
                }
            }
        }
    }
}
