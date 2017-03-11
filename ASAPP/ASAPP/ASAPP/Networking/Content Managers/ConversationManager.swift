//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

typealias ConversationManagerRequestBlock = ((_ fetchedEvents: [Event]?, _ error: String?) -> Void)

// MARK:- ConversationManagerDelegate

protocol ConversationManagerDelegate: class {
    func conversationManager(_ manager: ConversationManager, didReceiveMessageEvent messageEvent: Event)
    func conversationManager(_ manager: ConversationManager, didReceiveUpdatedMessageEvent messageEvent: Event)
    func conversationManager(_ manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withPreviewText previewText: String?, event: Event)
    func conversationManager(_ manager: ConversationManager, connectionStatusDidChange isConnected: Bool)
    func conversationManager(_ manager: ConversationManager, conversationStatusEventReceived event: Event, isLiveChat: Bool)
}

// MARK:- ConversationManager

class ConversationManager: NSObject {
    
    // MARK: Public Properties
    
    let credentials: Credentials
    let sessionManager: SessionManager
    
    weak var delegate: ConversationManagerDelegate?
    
    var currentSRSClassification: String?
    
    var isConnected: Bool {
        return socketConnection.isConnected
    }
    
    // MARK: Private Properties
    
    let socketConnection: SocketConnection
    
    let fileStore: ConversationFileStore
    
    let requestPrefix: String
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.sessionManager = SessionManager(credentials: credentials)
        self.socketConnection = SocketConnection(withCredentials: self.credentials)
        self.fileStore = ConversationFileStore(credentials: self.credentials)
        self.requestPrefix = credentials.isCustomer ? "customer/" : "rep/"
        super.init()
        
        self.socketConnection.delegate = self
    }
    
    deinit {
        socketConnection.delegate = nil
    }
}

// MARK:- Stored Messages 

extension ConversationManager {
    
    var storedMessages: [Event] {
        let storedEvents = fileStore.getSavedEvents() ?? [Event]()
        
        return storedEvents
    }
}

// MARK:- Entering/Leaving a Conversation

extension ConversationManager {
    
    // MARK: Entering/Exiting a Conversation
    
    func enterConversation() {
        DebugLog.d("Entering Conversation")
        
        socketConnection.connectIfNeeded()
    }
    
    func startSRS(completion: ((_ response: AppOpenResponse) -> Void)? = nil) {
        sendSRSRequest(path: "srs/AppOpen", params: nil) { (incomingMessage, request, responseTime) in
            
            if self.demo_OverrideStartSRS(completion: completion) {
                return
            }
            
            guard incomingMessage.type == .Response,
                let data = incomingMessage.bodyString?.data(using: String.Encoding.utf8),
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject],
                let appOpenResponse = AppOpenResponse.instanceWithJSON(jsonObject)
                else {
                    return
            }
            
            completion?(appOpenResponse)
        }
    }
    
    func exitConversation() {
        DebugLog.d("\n\nExiting Conversation\n")
        
        fileStore.save()
        socketConnection.disconnect()
    }
    
    func saveCurrentEvents(async: Bool = false) {
        fileStore.save(async: async)
    }
    
    func isConnected(retryConnectionIfNeeded: Bool = false) -> Bool {
        if !isConnected && retryConnectionIfNeeded {
            socketConnection.connectIfNeeded()
        }
        
        return isConnected
    }
}

// MARK:- Fetching Events

extension ConversationManager {
    
    func getLatestMessages(completion: @escaping ConversationManagerRequestBlock) {
        getMessageEvents(completion: completion)
    }
    
    func getMessageEvents(afterEvent: Event? = nil, completion: @escaping ConversationManagerRequestBlock) {
        let path = "\(requestPrefix)GetEvents"
        let afterSeq = afterEvent != nil ? afterEvent!.eventLogSeq : 0
        let params = ["AfterSeq" : afterSeq as AnyObject]
        
        socketConnection.sendRequest(withPath: path, params: params) { (message: IncomingMessage, request: SocketRequest?,  responseTime: ResponseTimeInMilliseconds) in
            Dispatcher.performOnBackgroundThread {
                
                let (eventList, eventsJSONArray, errorMessage) = message.parseEventList()
                if let eventsJSONArray = eventsJSONArray {
                    self.fileStore.replaceEventsWithJSONArray(eventsJSONArray: eventsJSONArray)
                }
                
                Dispatcher.performOnMainThread {
                    completion(eventList, errorMessage)
                }
            }
        }
    }
}

// MARK:- Sending Messages (PUBLIC)

extension ConversationManager {
    
    func sendTextMessage(_ message: String, completion: IncomingMessageHandler? = nil) {
        if demo_OverrideMessageSend(message: message) {
            return
        }
        
        _sendMessage(message, completion: completion)
    }
    
    func sendSRSSwitchToChat() {
        socketConnection.sendRequest(withPath: "srs/SwitchSRSToChat", params: nil);
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool = false) {
        if demo_OverrideMessageSend(message: query) {
            return
        }
        
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        let params = [
            "Text" : query as AnyObject,
            "SearchQuery" : query as AnyObject
        ]
        
        sendSRSRequest(path: path, params: params, isRequestFromPrediction: isRequestFromPrediction)
    }
    
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)? = nil) {
        let path = "\(requestPrefix)SendPictureMessage"
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            DebugLog.e("Unable to get JPEG data for image: \(image)")
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
    
    func sendRating(_ rating: Int, forIssueId issueId: Int, withFeedback feedback: String?, completion: ((_ success: Bool) -> Void)?) {
        let path = "customer/SendRatingAndFeedback"
        
        var params = [
            "FiveStarRating" : rating as AnyObject,
            "IssueId" : issueId as AnyObject
        ]
        if let feedback = feedback {
            params["Feedback"] = feedback as AnyObject
        }
        
        socketConnection.sendRequest(withPath: path, params: params, context: nil) { (message, request, responseTime) in
            completion?(message.type == .Response)
        }
    }
    
    func sendCreditCard(_ creditCard: CreditCard, completion: @escaping ((_ response: CreditCardResponse) -> Void)) {
        let path = "\(requestPrefix)SendCreditCard"
        let params = creditCard.toASAPPParams()
        
        socketConnection.sendRequest(withPath: path, params: params, context: nil)
        { (message: IncomingMessage, request: SocketRequest?, responseTime: ResponseTimeInMilliseconds) in
            let creditCardResponse = CreditCardResponse.from(json: message.body)
            completion(creditCardResponse)
        }
    }
    
    func sendUserTypingStatus(isTyping: Bool, withText text: String?) {
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
    
    func sendButtonItemSelection(_ buttonItem: SRSButtonItem,
                                 originalSearchQuery: String?,
                                 currentSRSEvent: Event?,
                                 completion: IncomingMessageHandler? = nil) {
        if demo_OverrideButtonItemSelection(buttonItem: buttonItem, completion: completion) {
            return
        }
        
        let action = buttonItem.action
        switch action.type {
        case .treewalk:
            sendSRSTreewalk(classification: action.name,
                            message: buttonItem.title,
                            originalSearchQuery: originalSearchQuery,
                            currentSRSEvent: currentSRSEvent,
                            completion: completion)
            break
            
        case .api:
            sendSRSAction(action: action.name,
                          withUserMessage: buttonItem.title,
                          payload: action.context,
                          completion: completion)
            break
            
        case .link:
            sendSRSLinkButtonTapped(buttonItem: buttonItem, completion: completion)
            break
            
        case .action:
            
            break
        }

    }
}

// MARK:- Sending Messages (PRIVATE)

extension ConversationManager {
    
    internal func _sendMessage(_ message: String, completion: IncomingMessageHandler? = nil) {
        let path = "\(requestPrefix)SendTextMessage"
        socketConnection.sendRequest(withPath: path,
                                     params: ["Text" : message as AnyObject],
                                     requestHandler: completion)
    }
    
    // MARK: SRS General
    
    fileprivate func sendSRSRequest(path: String,
                                    params: [String : AnyObject]?,
                                    isRequestFromPrediction: Bool = false,
                                    completion: IncomingMessageHandler? = nil) {
        
        Dispatcher.performOnBackgroundThread {
            var srsParams: [String : AnyObject] = [ "Context" : self.credentials.getContextString() as AnyObject].with(params)
            srsParams[ASAPP.CLIENT_TYPE_KEY] = ASAPP.CLIENT_TYPE_VALUE as AnyObject
            srsParams[ASAPP.CLIENT_VERSION_KEY] = ASAPP.clientVersion as AnyObject
            if let authToken = self.credentials.getAuthToken() {
                srsParams["Auth"] = authToken as AnyObject
            }
            
            Dispatcher.performOnMainThread {
                self.socketConnection.sendRequest(withPath: path, params: srsParams, context: nil, requestHandler: { (incomingMessage, request, responseTime) in
                    completion?(incomingMessage, request, responseTime)
                    
                    self.trackSRSRequest(path: path,
                                         requestUUID: request?.requestUUID,
                                         isPredictive: isRequestFromPrediction,
                                         params: params,
                                         responseTimeInMilliseconds: responseTime)
                })
            }
        }
    }
    
    // MARK: SRS Specific
    
    fileprivate func sendSRSTreewalk(classification: String,
                                     message: String,
                                     originalSearchQuery: String?,
                                     currentSRSEvent: Event?,
                                     completion: IncomingMessageHandler? = nil) {
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        var params = [
            "Text" : message as AnyObject,
            "Classification" : classification as AnyObject
        ]
        if let originalSearchQuery = originalSearchQuery {
            params["SearchQuery"] = originalSearchQuery as AnyObject
        }
        if let currentSRSEvent = currentSRSEvent {
            params["ParentEventLogSeq"] = currentSRSEvent.eventLogSeq as AnyObject
        }
        
        sendSRSRequest(path: path, params: params) { [weak self] (incomingMessage, request, responseTime) in
            completion?(incomingMessage, request, responseTime)
            self?.trackTreewalk(message: message, classification: classification)
        }
    }
    
    fileprivate func sendSRSAction(action: String,
                                   withUserMessage message: String,
                                   payload: [String : AnyObject]?,
                                   completion: IncomingMessageHandler? = nil) {
        let path = "srs/\(action)"
        var params = ["Text" : message as AnyObject]
        if let payload = payload {
            params["Payload"] = payload as AnyObject
        }
        
        sendSRSRequest(path: path, params: params, completion: completion)
    }
    
    fileprivate func sendSRSLinkButtonTapped(buttonItem: SRSButtonItem, completion: IncomingMessageHandler? = nil) {
        guard buttonItem.action.type == .link else {
            return
        }
        
        var params: [String : AnyObject] = [
            "Title" : buttonItem.title as AnyObject,
            "Link" : buttonItem.action.name as AnyObject
        ]
        if let deepLinkData = buttonItem.action.context as? AnyObject,
            let deepLinkDataJson = JSONUtil.stringify(deepLinkData) {
            params["Data"] = deepLinkDataJson as AnyObject
        }
        
        let path = "srs/CreateLinkButtonTapEvent"
        sendSRSRequest(path: path, params: params, completion: completion)
    }
    
}

// MARK:- SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        guard message.type == .Event, let event = Event.fromJSON(message.body) else {
            return
        }
        fileStore.addEventJSONString(eventJSONString: message.bodyString)
        
        if demo_OverrideReceivedMessageEvent(event: event) {
            return
        }
        
        
        // Entering / Exiting Live Chat
        if [EventType.conversationEnd, EventType.switchSRSToChat, EventType.newRep].contains(event.eventType) {
            let isLiveChat = event.eventType == .switchSRSToChat || event.eventType == .newRep
            delegate?.conversationManager(self, conversationStatusEventReceived: event, isLiveChat: isLiveChat)
        }
        
        
        // Typing Status
        if event.ephemeralType == .typingStatus {
            if let typingStatus = event.typingStatus {
                delegate?.conversationManager(self,
                                              didUpdateRemoteTypingStatus: typingStatus.isTyping,
                                              withPreviewText: nil,
                                              event: event)
            }
            return
        }
        
        // Ephemeral: Event Update
        if (event.ephemeralType == .eventStatus) {
            if let parentEventLogSeq = event.parentEventLogSeq {
                delegate?.conversationManager(self, didReceiveUpdatedMessageEvent: event)
            } else {
                DebugLog.d("Missing parentEventLogSeq on updated event")
            }
            return
        }
        
        // Message Event
        switch event.eventType {
        case .srsResponse, .conversationEnd, .switchSRSToChat, .newRep:
            Dispatcher.delay(600, closure: {
                self.delegate?.conversationManager(self, didReceiveMessageEvent: event)
            })
            break
            
        case .textMessage, .pictureMessage:
            delegate?.conversationManager(self, didReceiveMessageEvent: event)
            break
            
        default:
            // No-op
            break
        }
    }
    
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Established Connection")
        
        delegate?.conversationManager(self, connectionStatusDidChange: true)
    }
    
    func socketConnectionFailedToAuthenticate(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Authentication Failed")
        
        delegate?.conversationManager(self, connectionStatusDidChange: false)
    }
    
    func socketConnectionDidLoseConnection(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Connection Lost")
        
        delegate?.conversationManager(self, connectionStatusDidChange: false)
    }
}
