//
//  SRSConn.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSConn: NSObject {
    var ccData:[String:String] = [
        "R": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"TROUBLESHOOTING\",\"type\": \"label\"},{\"label\": \"TV\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RT\"}},{\"label\": \"INTERNET\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RI\"}},{\"label\": \"VOICE\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RV\"}},{\"label\": \"HOME\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RH\"}}]}",
        "RI": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"WHICH ONE OF THESE BEST DESCRIBES YOUR PROBLEM.\",\"type\": \"label\"},{\"label\": \"Connection\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RIC\"}},{\"label\": \"Browser\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RIB\"}},{\"label\": \"Email\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RIE\"}},{\"label\": \"WiFi\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RIW\"}}]}",
        "RIC": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"Which type of Connection problem are you experiencing?\",\"type\": \"label\"},{\"label\": \"Intermittent\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RICI\"}},{\"label\": \"Slow Speeds\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"RIS\"}},{\"type\": \"separator\"},{\"type\":\"icon\",\"value\":\"call\"},{\"label\": \"Or talk with our agents.\",\"type\": \"label\"},{\"label\": \"Schedule a Call\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}",
        "RIS": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"OUR TROUBLESHOOTING GUIDE CAN HELP YOU SOLVE THIS ISSUE.\",\"type\": \"label\"},{\"label\": \"Restart Device\",\"colorScheme\":\"dark\",\"icon\":\"deeplink\",\"type\": \"button\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"troubleshoot\",\"deepLinkData\":{\"service\":\"internet\",\"deviceId\":[\"123456\"]}}}},{\"label\": \"Troubleshoot your Internet Connection\",\"colorScheme\":\"dark\",\"icon\":\"article\",\"type\": \"button\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"troubleshoot\",\"deepLinkData\":{\"service\":\"internet\",\"deviceId\":[\"123456\"]}}}},{\"type\": \"separator\"},{\"type\":\"icon\",\"value\":\"call\"},{\"label\": \"Or talk with our agents.\",\"type\": \"label\"},{\"label\": \"Schedule a Call\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}",
        "RT": "{\"orientation\": \"verical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"OUR TROUBLESHOOTING GUIDE CAN HELP YOU SOLVE THIS ISSUE.\",\"type\": \"label\"},{\"label\": \"Cable Issue\",\"type\": \"button\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"troubleshoot\",\"deepLinkData\":{\"service\":\"video\",\"deviceId\":[\"09876\"]}}}}]}",
//        "B": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"Account #\",\"type\": \"info\",\"value\": \"728323981238921\"},{\"type\": \"separator\"},{\"icon\": \"icon_billing-a\",\"label\": \"Xfinity TV\",\"type\": \"info\",\"value\": \"60.85\"},{\"icon\": \"icon_billing-b\",\"label\": \"Xfinity Internet\",\"type\": \"info\",\"value\": \"65.95\"},{\"icon\": \"\",\"label\": \"Taxes, Surcharges and Fees\",\"type\": \"info\",\"value\": \"8.40\"},{\"type\": \"separator\"},{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"Total Due\",\"type\": \"info\",\"value\": \"$135.20\"},{\"type\": \"separator\"},{\"icon\": \"\",\"label\": \"Due Date\",\"type\": \"info\",\"value\": \"02/26/16\"}]},{\"type\": \"separator\"},{\"label\": \"View Account Details\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"BBC\"}},{\"label\": \"Understand your bill\",\"type\": \"button\",\"value\": {\"type\":\"AID\",\"content\":\"BBC\"}},{\"label\": \"Make A Payment\",\"type\": \"button\",\"colorScheme\": \"dark\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"payment\",\"deepLinkData\":{\"amount\":\"135.20\"}}}},{\"label\": \"Talk to an Agent\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}",
        "BP": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"YOUR CURRENT BALANCE:\",\"type\": \"info\",\"value\": \"$0.00\"}]},{\"type\": \"separator\"},{\"type\":\"icon\",\"value\":\"billPaid\"},{\"label\": \"No payment due. Thank you!\",\"type\": \"label\"},{\"type\":\"filler\"},{\"orientation\": \"vertical\",\"gravity\":\"down\",\"type\": \"itemlist\",\"value\": [{\"type\": \"separator\"},{\"label\": \"Make A Payment\",\"type\": \"button\",\"colorScheme\": \"dark\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"payment\",\"deepLinkData\":{\"amount\":\"135.20\"}}}},{\"label\": \"Talk to an Agent\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}]}",
//        "B": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"YOUR CURRENT BALANCE:\",\"type\": \"info\",\"value\": \"$0.00\"}]},{\"type\": \"separator\"},{\"type\":\"icon\",\"value\":\"autoPaySched\"},{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"Auto pay scheduled for:\",\"type\": \"info\",\"value\": \"May 10, 2016\"}]},{\"type\":\"filler\"},{\"orientation\": \"vertical\",\"gravity\":\"down\",\"type\": \"itemlist\",\"value\": [{\"type\": \"separator\"},{\"label\": \"Make A Payment\",\"type\": \"button\",\"colorScheme\": \"dark\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"payment\",\"deepLinkData\":{\"amount\":\"135.20\"}}}},{\"label\": \"Talk to an Agent\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}]}",
//        "BP": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"YOUR CURRENT BALANCE:\",\"type\": \"info\",\"value\": \"$201.26\"}]},{\"type\": \"separator\"},{\"type\":\"icon\",\"value\":\"billDue\"},{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"BALANCE DUE:\",\"type\": \"info\",\"value\": \"May 10, 2016\"}]},{\"type\":\"label\",\"label\":\"\"},{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"Your Bill This Month:\",\"type\": \"info\",\"value\": \"$145.20\"},{\"icon\": \"\",\"label\": \"Pending Payments:\",\"type\": \"info\",\"value\": \"$0.00\"},{\"icon\": \"\",\"label\": \"Recent Payment\",\"type\": \"info\",\"value\": \"$34.22\"}]},{\"label\": \"* Recent transactions may take a few days to reflect on your bill.\",\"type\": \"label\"},{\"type\":\"filler\"},{\"orientation\": \"vertical\",\"gravity\":\"down\",\"type\": \"itemlist\",\"value\": [{\"type\": \"separator\"},{\"label\": \"Make A Payment\",\"type\": \"button\",\"colorScheme\": \"dark\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"payment\",\"deepLinkData\":{\"amount\":\"135.20\"}}}},{\"label\": \"Talk to an Agent\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}]}",
//        "BP": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"YOUR CURRENT BALANCE:\",\"type\": \"info\",\"value\": \"$201.26\"}]},{\"type\": \"separator\"},{\"type\":\"icon\",\"value\":\"billPastDue\"},{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"\",\"type\": \"info\",\"value\": \"$100.68\",\"valueColor\":\"red\"}]},{\"label\": \"Please pay this amount to avoid service interruptions.\",\"type\": \"label\"},{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"Your Bill This Month:\",\"type\": \"info\",\"value\": \"$145.20\"},{\"icon\": \"\",\"label\": \"Pending Payments:\",\"type\": \"info\",\"value\": \"$0.00\"},{\"icon\": \"\",\"label\": \"Recent Payment\",\"type\": \"info\",\"value\": \"$34.22\"}]},{\"label\": \"* Recent transactions may take a few days to reflect on your bill.\",\"type\": \"label\"},{\"type\":\"filler\"},{\"orientation\": \"vertical\",\"gravity\":\"down\",\"type\": \"itemlist\",\"value\": [{\"type\": \"separator\"},{\"label\": \"Make A Payment\",\"type\": \"button\",\"colorScheme\": \"dark\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"payment\",\"deepLinkData\":{\"amount\":\"135.20\"}}}},{\"label\": \"Talk to an Agent\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}]}",
//        "B": "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"YOUR CURRENT BALANCE:\",\"type\": \"info\",\"value\": \"$201.26\"}]},{\"type\": \"separator\"},{\"type\":\"icon\",\"value\":\"credit\"},{\"orientation\": \"horizontal\",\"type\": \"itemlist\",\"value\": [{\"icon\": \"\",\"label\": \"\",\"type\": \"info\",\"value\": \"$100.68\",\"valueColor\":\"green\"}]},{\"label\": \"Please pay this amount to avoid service interruptions.\",\"type\": \"label\"},{\"type\":\"filler\"},{\"orientation\": \"vertical\",\"gravity\":\"down\",\"type\": \"itemlist\",\"value\": [{\"type\": \"separator\"},{\"label\": \"Make A Payment\",\"type\": \"button\",\"colorScheme\": \"dark\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"payment\",\"deepLinkData\":{\"amount\":\"135.20\"}}}},{\"label\": \"Talk to an Agent\",\"type\": \"button\",\"colorScheme\": \"light\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"call\",\"deepLinkData\":{}}}}]}]}",
        "O": "{\"orientation\": \"verical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"TALK WITH OUR AGENTS.\",\"type\": \"label\"},{\"label\": \"1-800-934-6489\",\"type\": \"button\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"dial\",\"deepLinkData\":{\"phone\":\"1-800-934-6489\"}}}}]}",
        "L": "{\"orientation\": \"verical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"A VERIFICATION PIN WILL BE SENT TO YOUR PHONE NUMBER ON FILE.\",\"type\": \"label\"},{\"label\": \"Send Pin\",\"type\": \"button\",\"value\": {\"type\":\"LINK\",\"content\":{\"deepLink\":\"modifyUserPassword\",\"deepLinkData\":{}}}}]}",
        // "L": "[{\"type\": \"label\",\"key\": \"\",\"value\": \"A VERIFICATION PIN WILL BE SENT TO YOUR PHONE NUMBER ON FILE.\"},{\"type\": \"button\",\"key\": \"Send Pin\",\"value\": \"AID:LPRPV\"}]",
        "LPRPV": "[{\"type\": \"label\",\"key\": \"\",\"value\": \"Type your pin below\"},{\"type\": \"pin\",\"key\": \"\",\"value\": \"\"},{\"type\": \"button\",\"key\": \"Verify\",\"value\": \"AID:LPRPVNP\"}]",
        "LPRPVNP": "[{\"type\": \"label\",\"key\": \"\",\"value\": \"Enter your new password\"},{\"type\": \"textfield\",\"key\": \"\",\"value\": \"\"},{\"type\": \"button\",\"key\": \"Continue\",\"value\": \"AID:LPRPVNPC\"}]",
        "LPRPVNPC": "[{\"type\": \"label\",\"key\": \"\",\"value\": \"Please re-enter the password\"},{\"type\": \"textfield\",\"key\": \"\",\"value\": \"\"},{\"type\": \"button\",\"key\": \"Set new password\",\"value\": \"AID:LPRPVNPCC\"}]",
        "LPRPVNPCC": "[{\"type\": \"label\",\"key\": \"\",\"value\": \"Password changed\"}]"
    ]
    
    
    let priority = DISPATCH_QUEUE_PRIORITY_HIGH
    let maxAuthTries = 1
    
    func createRequestData(query:String) -> String {
        let context = SRS.getContext()
        
        var postData = "search_query="+SRS.input.getQueryText()+"&a=8497404482821623&v=0.9.1&auth="+SRS.getAuth(maxAuthTries)
        if query != "" {
            postData += "&q="+query
        }
        postData += "&context="
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(context, options: NSJSONWritingOptions.PrettyPrinted)
            postData += String(data: jsonData, encoding: NSUTF8StringEncoding)!
        } catch let error as NSError {
            self.handleRequestError(error)
        }
        
        print(postData)
        return postData
    }
    
    func getHistoryForData() -> String {
        var history: String = ""
        do {
            var historyStack: [String] = []
            for content in SRS.content.contentStack {
                historyStack.append(String(data:content, encoding: NSUTF8StringEncoding)!)
            }
            if SRS.content.mData != nil {
                historyStack.append(String(data:SRS.content.mData, encoding: NSUTF8StringEncoding)!)
            }
            let jsonData = try NSJSONSerialization.dataWithJSONObject(historyStack, options: .PrettyPrinted)
            history = String(data: jsonData, encoding: NSUTF8StringEncoding)!
        } catch let error as NSError {
            self.handleRequestError(error)
        }
        print("HISTORY------------")
        print(history)
        return history
    }
    
    func handleRequestError(error:NSError) {
        print("Request failed", error.userInfo)
        let deepLinkError: [String:AnyObject] = [
            "NSError": error
        ]
        let deeplink: [String:AnyObject] = [
            "deepLink": "error",
            "deepLinkData": deepLinkError
        ]
        dispatch_async(dispatch_get_main_queue()) {
            if SRS.instance != nil {
                SRS.instance.colapse()
            }
            SRS.processDeepLink(deeplink)
        }
    }
    
    func handleRequestFailure(httpResponse:NSHTTPURLResponse) {
        let errorInfo: [String:AnyObject] = [
            NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode((httpResponse.statusCode))
        ]
        let error = NSError(domain: "com.asapp.srs", code: (httpResponse.statusCode), userInfo: errorInfo)
        let deepLinkError: [String:AnyObject] = [
            "NSError": error
        ]
        let deeplink: [String:AnyObject] = [
            "deepLink": "error",
            "deepLinkData": deepLinkError
        ]
        dispatch_async(dispatch_get_main_queue()) {
            if SRS.instance != nil {
                SRS.instance.colapse()
            }
            SRS.processDeepLink(deeplink)
        }
    }
    
    func request(query: String) {
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            self.doRequest(query)
        })
        SRS.prompt.prompt.text = ""
    }
    func openRequest() {
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            let url = NSURL(string: "https://srs-appopen.asapp.com/appopen")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.HTTPBody = (self.createRequestData("").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()))!.dataUsingEncoding(NSUTF8StringEncoding)
            print(url?.absoluteString)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
//                if error != nil {
//                    self.handleRequestError(error!)
//                    return
//                }
//                let httpResponse = response as? NSHTTPURLResponse
//                if httpResponse?.statusCode != 200 {
//                    self.handleRequestFailure(httpResponse!)
//                    return
//                }
//                print("APPOPEN:", NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
            task.resume()
        })
    }
    
    func dataRequest(action: String) {
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            let url = NSURL(string: "https://srs-data.asapp.com/data")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            
            let body = self.createRequestData("") + "&action=" + action + "&history=" + self.getHistoryForData()
            request.HTTPBody = (body.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()))!.dataUsingEncoding(NSUTF8StringEncoding)
            print(url?.absoluteString)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                //               print("DATA:", NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
            task.resume()
        })
    }
    
    func stopThinkAnimation(timer:NSTimer) {
        timer.invalidate()
    }
    func doRequest(query:String) {
        var animTimer: NSTimer!
        dispatch_async(dispatch_get_main_queue()) {
            animTimer = SRS.prompt.addRippleForDuration(1)
        }
        print("MAKE REQUEST",query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()))
//        let url = NSURL(string: "https://ccdemo.asapp.com/hier?q="+query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)
        let url = NSURL(string: "https://srs-hier.asapp.com/hier")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = (self.createRequestData(query).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()))!.dataUsingEncoding(NSUTF8StringEncoding)
        
        print("MAKE REQUEST", url?.absoluteString)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { 
                self.stopThinkAnimation(animTimer)
            })
            if error != nil {
                self.handleRequestError(error!)
                return
            }
            let httpResponse = response as? NSHTTPURLResponse
            if httpResponse?.statusCode != 200 {
                self.handleRequestFailure(httpResponse!)
                return
            }
            print("HEIR:", NSString(data: data!, encoding: NSUTF8StringEncoding))
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                if let classification = json["Classifications"] as? String {
                    print("Classifications:", classification)
                    self.requestByClassification(classification)
                }
            } catch let err as NSError {
                print(err)
                self.handleRequestError(err)
            }
        }
        task.resume()
        self.dataRequest(query)
    }
    
    func updateContent(val: String, classification: String, title: String) {
        let displayData = val.dataUsingEncoding(NSUTF8StringEncoding)
        print(NSString(data: displayData!, encoding: NSUTF8StringEncoding))
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            SRS.content.updateData(displayData!, isBackUpdate: false)
//            SRS.prompt.setPromptText(title)
            // Ignore server prompt text for now
            SRS.prompt.setPromptText("")
        })
    }
    
    func requestByClassification(classification:String) {
        var animTimer: NSTimer!
        dispatch_async(dispatch_get_main_queue()) {
            animTimer = SRS.prompt.addRippleForDuration(1)
        }
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            let url = NSURL(string: "https://srs-treewalk.asapp.com/treewalk")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.HTTPBody = (self.createRequestData(classification).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()))!.dataUsingEncoding(NSUTF8StringEncoding)
            print("MAKE REQUEST", url?.absoluteString)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopThinkAnimation(animTimer)
                })
                if error != nil {
                    self.handleRequestError(error!)
                    return
                }
                let httpResponse = response as? NSHTTPURLResponse
                if httpResponse?.statusCode != 200 {
                    self.handleRequestFailure(httpResponse!)
                    return
                }
                print("TREEWALK:", NSString(data: data!, encoding: NSUTF8StringEncoding))
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    if let classification = json["classification"] as? String {
                        print("Classifications:", classification)
                        var cTitle = classification
                        if let title = json["title"] as? String {
                            cTitle = title
                        }
                        if let val = json["content"] as? [String: AnyObject] {
                            do {
                                let jsonData = try NSJSONSerialization.dataWithJSONObject(val, options: NSJSONWritingOptions.PrettyPrinted)
                                print("Content FROM SERVER: ", String(data: jsonData, encoding: NSUTF8StringEncoding))
                                self.updateContent(String(data: jsonData, encoding: NSUTF8StringEncoding)!, classification: classification, title: cTitle)
                                return
                            } catch let err as NSError {
                                print(err)
                            }
                        }
                        if let val = self.ccData[classification] {
                            self.updateContent(val, classification: classification, title: cTitle)
                            return
                        }
                        
                        var val = "{\"orientation\": \"vertical\",\"type\": \"itemlist\",\"value\": [{\"label\": \"Use case not implemented in demo for code.\",\"type\": \"label\"},{\"label\": \"" + cTitle + "\",\"type\": \"label\"}]}"
                        self.updateContent(val, classification: classification, title: cTitle)
                    }
                } catch let err as NSError {
                    print(err)
                    self.handleRequestError(err)
                }
            }
            task.resume()
        })
    }
}