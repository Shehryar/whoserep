//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

// MARK:- DEBUG FLAGS

let TEST_ACTIONABLE_MESSAGES_LOCALLY = true


// MARK:- ConversationManagerDelegate

protocol ConversationManagerDelegate {
    func conversationManager(manager: ConversationManager, didReceiveMessageEvent messageEvent: Event)
    func conversationManager(manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withPreviewText previewText: String?, event: Event)
    func conversationManager(manager: ConversationManager, connectionStatusDidChange isConnected: Bool)
}

// MARK:- ConversationManager

class ConversationManager: NSObject {
    
    typealias ConversationManagerRequestBlock = ((fetchedEvents: [Event]?, error: String?) -> Void)
    
    // MARK: Properties
    
    var credentials: Credentials
    
    var delegate: ConversationManagerDelegate?
    
    // MARK: Private Properties
    
    private var socketConnection: SocketConnection
    
    private var conversationStore: ConversationStore
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.socketConnection = SocketConnection(withCredentials: self.credentials)
        self.conversationStore = ConversationStore(withCredentials: self.credentials)
        super.init()
        
        self.socketConnection.delegate = self
    }
    
    deinit {
        socketConnection.delegate = nil
    }
}

// MARK:- Network Actions

extension ConversationManager {
    var storedMessages: [Event] {
        return conversationStore.getMessageEvents()
    }

    func enterConversation() {
        socketConnection.connectIfNeeded()
    }
    
    func isConnected() -> Bool {
        return socketConnection.isConnected
    }
    
    func exitConversation() {
        socketConnection.disconnect()
    }
    
    func sendMessage(message: String, completion: (() -> Void)? = nil) {
        let path = "\(requestPrefix)SendTextMessage"
        socketConnection.sendRequest(withPath: path, params: ["Text" : message]) { (incomingMessage) in
            completion?()
        }
    }
    
    func sendPictureMessage(image: UIImage, completion: (() -> Void)? = nil) {
        let path = "\(requestPrefix)SendPictureMessage"
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            DebugLogError("Unable to get JPEG data for image: \(image)")
            return
        }
        let imageFileSize = imageData.length
        let params: [String : AnyObject] = [ "MimeType" : "image/jpeg",
                                             "FileSize" : imageFileSize,
                                             "PicWidth" : image.size.width,
                                             "PicHeight" : image.size.height ]
        
        socketConnection.sendRequest(withPath: path, params: params)
        socketConnection.sendRequestWithData(imageData) { (incomingMessage) in
            completion?()
        }
    }
    
    func updateCurrentUserTypingStatus(isTyping: Bool, withText text: String?) {
        if credentials.isCustomer {
            let path = "\(requestPrefix)NotifyTypingPreview"
            let params = [ "Text" : text ?? "" ]
            socketConnection.sendRequest(withPath: path, params: params)
        } else {
            let path = "\(requestPrefix)NotifyTypingStatus"
            let params = [ "IsTyping" : isTyping ]
            socketConnection.sendRequest(withPath: path, params: params)
        }
    }
    
    func getLatestMessages(completion: ConversationManagerRequestBlock) {
        getMessageEvents { (fetchedEvents, error) in
            if let fetchedEvents = fetchedEvents {
                self.conversationStore.updateWithRecentMessageEvents(fetchedEvents)
                completion(fetchedEvents: fetchedEvents, error: error)
            }
        }
    }

    /// Returns all types of events
    func getMessageEvents(afterEvent: Event? = nil, completion: ConversationManagerRequestBlock) {
        let path = "\(requestPrefix)GetEvents"
        var params = [String : AnyObject]()
        
        var afterSeq = 0
        if let afterEvent = afterEvent {
            afterSeq = afterEvent.eventLogSeq
        }
        params["AfterSeq"] = afterSeq
        
        socketConnection.sendRequest(withPath: path, params: params) { (message: IncomingMessage) in
            var fetchedEvents: [Event]?
            var errorMessage: String?
            
            if message.type == .Response {
                if let fetchedEventsJSON = (message.body?["EventList"] as? [AnyObject] ??
                    message.body?["Events"] as? [AnyObject]) {
                    fetchedEvents = [Event]()
                    for eventJSON in fetchedEventsJSON {
                        guard let eventJSON = eventJSON as? [String : AnyObject] else {
                            continue
                        }
                        if let event = Event(withJSON: eventJSON) {
                            fetchedEvents?.append(event)
                        }
                    }
                }
            } else if message.type == .ResponseError {
                errorMessage = message.debugError
            }
            
            let numberOfEventsFetched = (fetchedEvents != nil ? fetchedEvents!.count : 0)
            if numberOfEventsFetched == 0 {
                errorMessage = errorMessage ?? "No results returned."
            }
            
            DebugLog("Fetched \(numberOfEventsFetched) events\(errorMessage != nil ? "with error: \(errorMessage!)" : "")")
            
            completion(fetchedEvents: fetchedEvents, error: errorMessage)
        }
    }
    
    private var requestPrefix: String {
        return credentials.isCustomer ? "customer/" : "rep/"
    }
    
    // MARK:- SRS
    
    func startSRS() {
        socketConnection.sendRequest(withPath: "srs/AppOpen",
                                     params: [
                                        "access_token" : "tokentokentoken",
                                        "expires_in" : 30,
                                        "issued_time" : NSDate().timeIntervalSince1970
        ]) { (incomingMessage) in
            
        }
    }
    
    func sendSRSQuery(query: String, completion: (() -> Void)? = nil) {
        socketConnection.sendRequest(withPath: "srs/HierAndTreewalk", params: ["Q" : query]) { (incomingMessage) in
            completion?()
        }
    }
    
    private func sendSRSTreewalk(query: String, completion: (() -> Void)? = nil) {
        socketConnection.sendRequest(withPath: "srs/Treewalk", params: ["Q" : query]) { (incomingMessage) in
            completion?()
        }
    }
    
    func sendSRSButtonItemSelection(buttonItem: SRSButtonItem, completion: (() -> Void)? = nil) {
        guard let srsQuery = buttonItem.srsValue else {
            return
        }
        
        sendMessage(buttonItem.title, completion: completion)
        
        sendSRSTreewalk(srsQuery)
    }
    
    private func testSRSButtonSelectionWithBillPayment(buttonItem: SRSButtonItem, completion: (() -> Void)? = nil) {
        sendMessage(buttonItem.title, completion: completion)
        
        Dispatcher.delay(600, closure: {
            if let sampleBillEvent = Event.sampleBillSummaryEvent() {
                self.delegate?.conversationManager(self, didReceiveMessageEvent: sampleBillEvent)
            }
        })
    }
}

// MARK:- SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    func socketConnection(socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        
        if message.type == .Event {
            if let event = Event(withJSON: message.body) {
                conversationStore.addEvent(event)
                
                switch event.eventType {
                case .SRSResponse:
                    // MITCH MITCH MITCH TEST TEST TESTING - Artifical Delay
                    Dispatcher.delay(600, closure: { 
                        self.delegate?.conversationManager(self, didReceiveMessageEvent: event)
                    })
                    break
                    
                case .TextMessage, .PictureMessage:
                    delegate?.conversationManager(self, didReceiveMessageEvent: event)
                    break
                  
                case .None:
                    switch event.ephemeralType {
                    case .TypingStatus:
                        if let typingStatus = event.typingStatus {
                            delegate?.conversationManager(self,
                                                          didUpdateRemoteTypingStatus: typingStatus.isTyping,
                                                          withPreviewText: nil,
                                                          event: event)
                        }
                        break
                        
                    case .TypingPreview:
                        if let typingPreview = event.typingPreview {
                            delegate?.conversationManager(self,
                                                          didUpdateRemoteTypingStatus: !typingPreview.previewText.isEmpty,
                                                          withPreviewText: typingPreview.previewText,
                                                          event: event)
                        }
                        break
                        
                    default:
                        // Not yet handled
                        break
                    }
                    break
                    
                    
                default:
                    // Not yet handled
                    break
                }
                
            }
        }
    }

    func socketConnectionEstablishedConnection(socketConnection: SocketConnection) {
        delegate?.conversationManager(self, connectionStatusDidChange: true)
    }
    
    func socketConnectionFailedToAuthenticate(socketConnection: SocketConnection) {
        delegate?.conversationManager(self, connectionStatusDidChange: false)
    }
    
    func socketConnectionDidLoseConnection(socketConnection: SocketConnection) {
        delegate?.conversationManager(self, connectionStatusDidChange: false)
    }
}
