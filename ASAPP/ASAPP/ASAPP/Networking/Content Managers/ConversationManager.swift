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
    func conversationManager(_ manager: ConversationManager, didReceiveMessageEvent messageEvent: Event)
    func conversationManager(_ manager: ConversationManager, didReceiveUpdatedMessageEvent messageEvent: Event)
    func conversationManager(_ manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withPreviewText previewText: String?, event: Event)
    func conversationManager(_ manager: ConversationManager, connectionStatusDidChange isConnected: Bool)
}

// MARK:- ConversationManager

class ConversationManager: NSObject {
    
    typealias ConversationManagerRequestBlock = ((_ fetchedEvents: [Event]?, _ error: String?) -> Void)
    
    // MARK: Properties
    
    var credentials: Credentials
    
    var delegate: ConversationManagerDelegate?
    
    // MARK: Private Properties
    
    internal var socketConnection: SocketConnection
    
    internal var fileStore: ConversationFileStore
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials, environment: ASAPPEnvironment) {
        self.credentials = credentials
        self.socketConnection = SocketConnection(withCredentials: self.credentials)
        self.fileStore = ConversationFileStore(credentials: self.credentials)
        super.init()
        
        self.socketConnection.delegate = self
    }
    
    deinit {
        socketConnection.delegate = nil
    }
}

// MARK:- Network Actions

extension ConversationManager {
    
    // MARK: Stored Messages
    
    var storedMessages: [Event] {
        let storedEvents = fileStore.getSavedEvents() ?? [Event]()
        
        return storedEvents
    }
    
    // MARK: Entering/Exiting a Conversation
    
    func enterConversation() {
        socketConnection.connectIfNeeded()
    }
    
    func isConnected() -> Bool {
        return socketConnection.isConnected
    }
    
    func exitConversation() {
        fileStore.save()
        socketConnection.disconnect()
    }
    
    // MARK: Sending Messages
    
    func sendMessage(_ message: String, completion: (() -> Void)? = nil) {
        let path = "\(requestPrefix)SendTextMessage"
        socketConnection.sendRequest(withPath: path, params: ["Text" : message as AnyObject]) { (incomingMessage) in
            completion?()
        }
    }
    
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)? = nil) {
        let path = "\(requestPrefix)SendPictureMessage"
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            DebugLogError("Unable to get JPEG data for image: \(image)")
            return
        }
        let imageFileSize = imageData.count
        let params: [String : AnyObject] = [ "MimeType" : "image/jpeg" as AnyObject,
                                             "FileSize" : imageFileSize as AnyObject,
                                             "PicWidth" : image.size.width as AnyObject,
                                             "PicHeight" : image.size.height as AnyObject ]
        
        socketConnection.sendRequest(withPath: path, params: params)
        socketConnection.sendRequestWithData(imageData) { (incomingMessage) in
            completion?()
        }
    }
    
    func updateCurrentUserTypingStatus(_ isTyping: Bool, withText text: String?) {
        if credentials.isCustomer {
            let path = "\(requestPrefix)NotifyTypingPreview"
            let params = [ "Text" : text ?? "" ]
            socketConnection.sendRequest(withPath: path, params: params as [String : AnyObject]?)
        } else {
            let path = "\(requestPrefix)NotifyTypingStatus"
            let params = [ "IsTyping" : isTyping ]
            socketConnection.sendRequest(withPath: path, params: params as [String : AnyObject]?)
        }
    }
    
    // MARK: Fetching Events
    
    func getLatestMessages(_ completion: @escaping ConversationManagerRequestBlock) {
        getMessageEvents { (fetchedEvents, error) in
            if let fetchedEvents = fetchedEvents {
                completion(fetchedEvents, error)
            }
        }
    }
    
    /// Returns all types of events
    func getMessageEvents(_ afterEvent: Event? = nil, completion: @escaping ConversationManagerRequestBlock) {
        let path = "\(requestPrefix)GetEvents"
        var params = [String : AnyObject]()
        
        var afterSeq = 0
        if let afterEvent = afterEvent {
            afterSeq = afterEvent.eventLogSeq
        }
        params["AfterSeq"] = afterSeq as AnyObject?
        
        socketConnection.sendRequest(withPath: path, params: params) { (message: IncomingMessage) in
            self.handleGetMessageEventsResponse(message: message, completion: completion)
        }
    }
    
    fileprivate func handleGetMessageEventsResponse(message: IncomingMessage, completion: @escaping ConversationManagerRequestBlock) {
        
        Dispatcher.performOnBackgroundThread {
            
            var fetchedEvents: [Event]?
            var errorMessage: String?
            
            if message.type == .Response {
                if let fetchedEventsJSON = (message.body?["EventList"] as? [AnyObject] ?? message.body?["Events"] as? [AnyObject]) {
                    
                    fetchedEvents = [Event]()
                    for eventJSON in fetchedEventsJSON {
                        guard let eventJSON = eventJSON as? [String : AnyObject] else {
                            continue
                        }
                        if let event = Event(withJSON: eventJSON) {
                            fetchedEvents?.append(event)
                        }
                    }
                    if let fetchedEventsJSON = fetchedEventsJSON as? [[String : AnyObject]]  {
                        self.fileStore.replaceEventsWithJSONArray(eventsJSONArray: fetchedEventsJSON)
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
            
            Dispatcher.performOnMainThread {
                completion(fetchedEvents, errorMessage)
            }
        }
    }
    
    fileprivate var requestPrefix: String {
        return credentials.isCustomer ? "customer/" : "rep/"
    }
}

// MARK:- SRS

extension ConversationManager {
    
    // MARK: SRS Public
    
    func startSRS(completion: ((_ response: SRSAppOpenResponse) -> Void)? = nil) {
        sendSRSRequest(path: "srs/AppOpen", params: nil) { (incomingMessage) in
            
            if let demoResponse = self.demo_AppOpenResponse() {
                completion?(demoResponse)
                return
            }
            
            if incomingMessage.type == .Response {
                if let data = incomingMessage.bodyString?.data(using: String.Encoding.utf8) {
                    if let  jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] {
                        if let object = SRSAppOpenResponse.instanceWithJSON(jsonObject) as? SRSAppOpenResponse {
                            completion?(object)
                        } else {
                            
                        }
                    } else {
                        
                    }
                } else {
                    
                }
            }
        }
    }
    
    /// Original / new-search query to srs
    func sendMessageAsSRSQuery(_ query: String, completion: (() -> Void)? = nil) {
        if demo_OverrideMessageSend(message: query, completion: completion) {
            return
        }
        
        let params = [
            "Text" : query as AnyObject,
            "SearchQuery" : query as AnyObject
        ]
        
        sendSRSRequest(path: "srs/SendTextMessageAndHierAndTreewalk", params: params) { (incomingMessage) in
            completion?()
        }
    }
    
    func sendSRSButtonItemSelection(_ buttonItem: SRSButtonItem, originalSearchQuery: String?, completion: (() -> Void)? = nil) {
        
        if demo_OverrideButtonItemSelection(buttonItem: buttonItem, completion: completion) {
            return
        }
        
        switch buttonItem.type {
        case .SRS:
            if let srsQuery = buttonItem.srsValue {
                sendSRSTreewalk(srsQuery, withMessage: buttonItem.title, originalSearchQuery: originalSearchQuery)
            }
            break
            
        case .Action:
            if let actionName = buttonItem.actionName {
                DebugLog("Sending action: srs/\(actionName)")
                sendMessage(buttonItem.title)
                sendSRSRequest(path: "srs/\(actionName)", params: nil, requestHandler: { (incomingMessage) in
                    DebugLog("\n\nReceived Response from action:\n\(incomingMessage.body)\n")
                    completion?()
                })
            }
            break
            
        case .InAppLink, .Link:
            DebugLogError("ConversationManager cannot handle button with type \(buttonItem.type)")
            break
        }
    }
    
    // MARK: SRS Private
    
    fileprivate func sendSRSRequest(path: String, params: [String : AnyObject]?, requestHandler: IncomingMessageHandler?) {
        Dispatcher.performOnBackgroundThread {
            var srsParams = params ?? [String : AnyObject]()
            if let authToken = self.credentials.getAuthToken() {
                srsParams["Auth"] = authToken as AnyObject
            }
            srsParams["Context"] = self.credentials.getContextString() as AnyObject

            self.socketConnection.sendRequest(withPath: path, params: srsParams, context: nil, requestHandler: { (incomingMessage) in
                Dispatcher.performOnMainThread {
                    requestHandler?(incomingMessage)
                }
            })
        }
    }
    
    fileprivate func sendSRSTreewalk(_ query: String, withMessage message: String, originalSearchQuery: String?, completion: (() -> Void)? = nil) {
        var params = ["Text" : message as AnyObject,
                      "Classification" : query as AnyObject]
        if let originalSearchQuery = originalSearchQuery {
            params["SearchQuery"] = originalSearchQuery as AnyObject
        }
        
        sendSRSRequest(path: "srs/SendTextMessageAndHierAndTreewalk", params: params) { (incomingMessage) in
            completion?()
        }
    }
}

// MARK:- SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        
        if message.type == .Event {
            if let event = Event(withJSON: message.body) {
                fileStore.addEventJSONString(eventJSONString: message.bodyString)
                
                
                if demo_OverrideReceivedMessageEvent(event: event) {
                    return
                }
                
                
                switch event.eventType {
                case .srsResponse:
                    Dispatcher.delay(600, closure: {
                        self.delegate?.conversationManager(self, didReceiveMessageEvent: event)
                    })
                    break
                    
                case .textMessage, .pictureMessage:
                    delegate?.conversationManager(self, didReceiveMessageEvent: event)
                    break
                    
                case .none:
                    switch event.ephemeralType {
                    case .eventStatus:
                        if let parentEventLogSeq = event.parentEventLogSeq {
                            event.eventLogSeq = parentEventLogSeq
                            event.eventType = .srsResponse
                            event.srsResponse = SRSResponse.instanceWithJSON(event.eventJSONObject) as? SRSResponse
                            delegate?.conversationManager(self, didReceiveUpdatedMessageEvent: event)
                        }
                        break
                        
                    case .typingStatus:
                        if let typingStatus = event.typingStatus {
                            delegate?.conversationManager(self,
                                                          didUpdateRemoteTypingStatus: typingStatus.isTyping,
                                                          withPreviewText: nil,
                                                          event: event)
                        }
                        break
                        
                    case .typingPreview:
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
    
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection) {
        DebugLog("ConversationManager: Established Connection")
        
        delegate?.conversationManager(self, connectionStatusDidChange: true)
    }
    
    func socketConnectionFailedToAuthenticate(_ socketConnection: SocketConnection) {
        DebugLog("ConversationManager: Authentication Failed")
        
        delegate?.conversationManager(self, connectionStatusDidChange: false)
    }
    
    func socketConnectionDidLoseConnection(_ socketConnection: SocketConnection) {
        DebugLog("ConversationManager: Connection Lost")
        
        delegate?.conversationManager(self, connectionStatusDidChange: false)
    }
}
