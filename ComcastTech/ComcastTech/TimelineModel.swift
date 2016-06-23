//
//  TimelineModel.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum CCServices {
    case Internet
    case Video
    case Phone
    case Home
}

class TimelineModel: NSObject, TimelineDataSource {
    
    struct CCAccount {
        let Id: UInt
        let Name: String
        let Services: [CCServices]
        let Length: String
        let Status: String
        let Activities: [CCActivity]
        let Journeies: [CCJourney]
    }
    
    struct CCActivity {
        let Id: UInt
        let Title: String
        let Description: String
    }
    
    struct CCJourney {
        let Id: UInt
        let Title: String
        let Items: [CCJourneyItem]
    }
    
    struct CCJourneyItem {
        let key: String
        let value: String
    }
    
    var mAccount: CCAccount!
    
    func fetchTimeline() {
        // Dummy timeline for now
        
        let activity1 = CCActivity(Id: 1, Title: "Internet Health", Description: "Henry has been experiencing Internet Issues since January 7.")
        let activity2 = CCActivity(Id: 2, Title: "Truck Rolls", Description: "Technician Linda Lou visited on 01/12/2016 for 2 hours resulting in a patched internet connection.")
        
        let journeyItem1 = CCJourneyItem(key: "SIK Shipped on", value: "02/02/16")
        let journeyItem2 = CCJourneyItem(key: "Next", value: "Activation")
        let journeyItem3 = CCJourneyItem(key: "Customer Effort", value: "High")
        
        let journeyItem4 = CCJourneyItem(key: "45 min Service Call on", value: "02/01/16")
        
        let journey1 = CCJourney(Id: 1, Title: "Voice Setup", Items: [journeyItem1, journeyItem2, journeyItem3])
        let journey2 = CCJourney(Id: 1, Title: "Internet Health", Items: [journeyItem4, journeyItem2, journeyItem3])
        let journey3 = CCJourney(Id: 1, Title: "Voice Setup", Items: [journeyItem1, journeyItem2, journeyItem3])
        let journey4 = CCJourney(Id: 1, Title: "Internet Health", Items: [journeyItem4, journeyItem2, journeyItem3])
        let journey5 = CCJourney(Id: 1, Title: "Voice Setup", Items: [journeyItem1, journeyItem2, journeyItem3])
        let journey6 = CCJourney(Id: 1, Title: "Internet Health", Items: [journeyItem4, journeyItem2, journeyItem3])
        let journey7 = CCJourney(Id: 1, Title: "Voice Setup", Items: [journeyItem1, journeyItem2, journeyItem3])
        let journey8 = CCJourney(Id: 1, Title: "Internet Health", Items: [journeyItem4, journeyItem2, journeyItem3])
        
        mAccount = CCAccount(Id: 12345678, Name: "Henry Ramososos", Services: [.Internet, .Video, .Phone, .Home], Length: "3 years 2 months", Status: "on time", Activities: [activity1, activity2], Journeies: [journey1, journey2, journey3, journey4, journey5, journey6, journey7, journey8])
    }
    
    func fetchTimelineIfNeeded() {
        if mAccount == nil {
            fetchTimeline()
        }
    }
    
    // MARK: - TimelineDataSource
    
    func timelineAccount() -> TimelineModel.CCAccount {
        fetchTimelineIfNeeded()
        return mAccount
    }
    
    func timelineActivities() -> [TimelineModel.CCActivity] {
        fetchTimelineIfNeeded()
        return mAccount.Activities
    }
    
    func timelineJourneys() -> [TimelineModel.CCJourney] {
        fetchTimelineIfNeeded()
        return mAccount.Journeies
    }
}