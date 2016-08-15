//
//  SRSSampleData.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum SRSItemType {
    case ItemList
}

enum SRSOrientation {
    case Vertical
}

enum SRSItemListItemType {
    case Label
    case Button
}

enum SRSItemListItemValueType {
    case AID
}

class SRSItem: NSObject {
    let type: SRSItemType
    let orientation: SRSOrientation
    let items: [SRSItemListItem]
    
    init(type: SRSItemType, orientation: SRSOrientation = .Vertical, items: [SRSItemListItem]) {
        self.type = type
        self.orientation = orientation
        self.items = items
        super.init()
    }
}

class SRSItemListItem: NSObject {
    let label: String
    let type: SRSItemListItemType
    let valueType: SRSItemListItemValueType
    let valueContent: String
    
    init(label: String,
         type: SRSItemListItemType,
         valueType: SRSItemListItemValueType,
         valueContent: String) {
        self.label = label
        self.type = type
        self.valueType = valueType
        self.valueContent = valueContent
        super.init()
    }
    
}

class SRSItemListItemValue: NSObject {
    var type: String
    var content: String
    
    init(type: String, content: String) {
        self.type = type
        self.content = content
        super.init()
    }
}

class SRSSampleData: NSObject {
    
    let R = SRSItem(
        type: .ItemList,
        items: [
            SRSItemListItem(
                label: "TV",
                type: .Button,
                valueType: .AID,
                valueContent: "RT"),
            SRSItemListItem(
                label: "Internet",
                type: .Button,
                valueType: .AID,
                valueContent: "RI"),
            SRSItemListItem(
                label: "Voice",
                type: .Button,
                valueType: .AID,
                valueContent: "RI"),
            SRSItemListItem(
                label: "Home",
                type: .Button,
                valueType: .AID,
                valueContent: "RH"),
        ])
    
    let RI = SRSItem(
        type: .ItemList,
        items: [
            SRSItemListItem(
                label: "Connection",
                type: .Button,
                valueType: .AID,
                valueContent: "RIC"),
            SRSItemListItem(
                label: "Browser",
                type: .Button,
                valueType: .AID,
                valueContent: "RIB"),
            SRSItemListItem(
                label: "Email",
                type: .Button,
                valueType: .AID,
                valueContent: "RIE"),
            SRSItemListItem(
                label: "Wi-Fi",
                type: .Button,
                valueType: .AID,
                valueContent: "RIW"),
        ])
    
    let RIC = SRSItem(
        type: .ItemList,
        items: [
            SRSItemListItem(
                label: "Intermittent",
                type: .Button,
                valueType: .AID,
                valueContent: "RICI"),
            SRSItemListItem(
                label: "Slow Speeds",
                type: .Button,
                valueType: .AID,
                valueContent: "RIS"),
            SRSItemListItem(
                label: "Email",
                type: .Button,
                valueType: .AID,
                valueContent: "RIE"),
            SRSItemListItem(
                label: "Wi-Fi",
                type: .Button,
                valueType: .AID,
                valueContent: "RIW"),
        ])
    
    
    
    func sampleResponse() -> SRSItem {
        return R
    }
    
    func sampleResponseForContent(content: String) -> SRSItem? {
        switch content {
        case "R": return R
        case "RI": return RI
        case "RIC": return RIC
        default: return nil
        }
    }

    /*
     
        "RIS" : [
            "orientation" : "vertical",
            "type" : "itemlist",
            "value" : [
                [
                    "label" : "OUR TROUBLESHOOTING GUIDE CAN HELP YOU SOLVE THIS ISSUE.",
                    "type" : "label"
                ],
                [
                    "label" : "Restart Device",
                    "colorScheme" : "dark",
                    "icon" : "deeplink",
                    "type" : "button",
                    "value" : [
                        "type" : "LINK",
                        "content" : [
                            "deepLink" : "troubleshoot",
                            "deepLinkData" : [
                                "service" : "internet",
                                "deviceId" : [
                                    "123456"
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "label" : "Troubleshoot your Internet Connection",
                    "colorScheme" : "dark",
                    "icon" : "article",
                    "type" : "button",
                    "value" : [
                        "type" : "LINK",
                        "content" : [
                            "deepLink" : "troubleshoot",
                            "deepLinkData" : [
                                "service" : "internet",
                                "deviceId" : [
                                    "123456"
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "type" : "separator"
                ],
                [
                    "type" : "icon",
                    "value" : "call"
                ],
                [
                    "label" : "Or talk with our agents.",
                    "type" : "label"
                ],
                [
                    "label" : "Schedule a Call",
                    "type" : "button",
                    "colorScheme" : "light",
                    "value" : [
                        "type" : "LINK",
                        "content" : [
                            "deepLink" : "call",
                            "deepLinkData" :[]
                        ]
                    ]
                ]
            ]
        ],
        
        "RT" : [
            "orientation" : "verical",
            "type" : "itemlist",
            "value" : [
                [
                    "label" : "OUR TROUBLESHOOTING GUIDE CAN HELP YOU SOLVE THIS ISSUE.",
                    "type" : "label"
                ],
                [
                    "label" : "Cable Issue",
                    "type" : "button",
                    "value" : [
                        "type" : "LINK",
                        "content" : [
                            "deepLink" : "troubleshoot",
                            "deepLinkData" : [
                                "service" : "video",
                                "deviceId" : [
                                    "09876"
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ],
     
     
     "R" : [
     "orientation" : "vertical",
     "type" : "itemlist",
     "value" : [
     [
     "label" : "TROUBLESHOOTING",
     "type" : "label"
     ],
     [
     "label" : "TV",
     "type" : "button",
     "value" : [
     "type" : "AID",
     "content" : "RT"
     ]
     ],
     [
     "label" : "INTERNET",
     "type" : "button",
     "value" : [
     "type" : "AID",
     "content" : "RI"
     ]
     ],
     [
     "label" : "VOICE",
     "type" : "button",
     "value" : [
     "type" : "AID",
     "content" : "RV"
     ]
     ],
     [
     "label" : "HOME",
     "type" : "button",
     "value" : [
     "type" : "AID",
     "content" : "RH"
     ]
     ]
     ]
     ],

     
        "BP" : [
            "orientation" : "vertical",
            "type" : "itemlist",
            "value" : [
                [
                    "orientation" : "horizontal",
                    "type" : "itemlist",
                    "value" : [
                        [
                            "icon" : "",
                            "label" : "YOUR CURRENT BALANCE:",
                            "type" : "info",
                            "value" : "$0.00"
                        ]
                    ]
                ],
                [
                    "type" : "separator"
                ],
                [
                    "type" : "icon",
                    "value" : "billPaid"
                ],
                [
                    "label" : "No payment due. Thank you!",
                    "type" : "label"
                ],
                [
                    "type" : "filler"
                ],
                [
                    "orientation" : "vertical",
                    "gravity" : "down",
                    "type" : "itemlist",
                    "value" : [
                        [
                            "type" : "separator"
                        ],
                        [
                            "label" : "Make A Payment",
                            "type" : "button",
                            "colorScheme" : "dark",
                            "value" : [
                                "type" : "LINK",
                                "content" : [
                                    "deepLink" : "payment",
                                    "deepLinkData" : [
                                        "amount" : "135.20"
                                    ]
                                ]
                            ]
                        ],
                        [
                            "label" : "Talk to an Agent",
                            "type" : "button",
                            "colorScheme" : "light",
                            "value" : [
                                "type" : "LINK",
                                "content" : [
                                    "deepLink" : "call",
                                    "deepLinkData" : []
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ],
        
        
        
        "O" : [
            "orientation" : "verical",
            "type" : "itemlist",
            "value" : [
                [
                    "label" : "TALK WITH OUR AGENTS.",
                    "type" : "label"
                ],
                [
                    "label" : "1-800-934-6489",
                    "type" : "button",
                    "value" : [
                        "type" : "LINK",
                        "content" : [
                            "deepLink" : "dial",
                            "deepLinkData" : [
                                "phone" : "1-800-934-6489"
                            ]
                        ]
                    ]
                ]
            ]
        ],
        
        "L" : [
            "orientation" : "verical",
            "type" : "itemlist",
            "value" : [
                [
                    "label" : "A VERIFICATION PIN WILL BE SENT TO YOUR PHONE NUMBER ON FILE.",
                    "type" : "label"
                ],
                [
                    "label" : "Send Pin",
                    "type" : "button",
                    "value" : [
                        "type" : "LINK",
                        "content" : [
                            "deepLink" : "modifyUserPassword",
                            "deepLinkData" : []
                        ]
                    ]
                ]
            ]
        ],
        
        "LPRPV" : [
            [
                "type" : "label",
                "key" : "",
                "value" : "Type your pin below"
            ],
            [
                "type" : "pin",
                "key" : "",
                "value" : ""
            ],
            [
                "type" : "button",
                "key" : "Verify",
                "value" : "AID:LPRPVNP"
            ]
        ],
        
        "LPRPVNP" : [
            [
                "type" : "label",
                "key" : "",
                "value" : "Enter your new password"
            ],
            [
                "type" : "textfield",
                "key" : "",
                "value" : ""
            ],
            [
                "type" : "button",
                "key" : "Continue",
                "value" : "AID:LPRPVNPC"
            ]
        ],
        
        "LPRPVNPC" : [
            [
                "type" : "label",
                "key" : "",
                "value" : "Please re-enter the password"
            ],
            [
                "type" : "textfield",
                "key" : "",
                "value" : ""
            ],
            [
                "type" : "button",
                "key" : "Set new password",
                "value" : "AID:LPRPVNPCC"
            ]
        ],
        
        "LPRPVNPCC" : [
            [
                "type" : "label",
                "key" : "",
                "value" : "Password changed"
            ]
        ],
 
 
 */
        
        /**
         *    Previously Commented Out
         */
        
 
 
        
        /**
        
        "B" : ["orientation" : "vertical", "type" : "itemlist", "value" : [["icon" : "", "label" : "Account #", "type" : "info", "value" : "728323981238921"],["type" : "separator"],["icon" : "icon_billing-a", "label" : "Xfinity TV", "type" : "info", "value" : "60.85"],["icon" : "icon_billing-b", "label" : "Xfinity Internet", "type" : "info", "value" : "65.95"],["icon" : "", "label" : "Taxes, Surcharges and Fees", "type" : "info", "value" : "8.40"],["type" : "separator"],["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "Total Due", "type" : "info", "value" : "$135.20"],["type" : "separator"],["icon" : "", "label" : "Due Date", "type" : "info", "value" : "02/26/16"]]],["type" : "separator"],["label" : "View Account Details", "type" : "button", "value" : ["type" : "AID", "content" : "BBC"]],["label" : "Understand your bill", "type" : "button", "value" : ["type" : "AID", "content" : "BBC"]],["label" : "Make A Payment", "type" : "button", "colorScheme" : "dark", "value" : ["type" : "LINK", "content" :["deepLink" : "payment", "deepLinkData" :["amount" : "135.20"]]]],["label" : "Talk to an Agent", "type" : "button", "colorScheme" : "light", "value" : ["type" : "LINK", "content" :["deepLink" : "call", "deepLinkData" :[]]]]]],
        
        "B" : ["orientation" : "vertical", "type" : "itemlist", "value" : [["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "YOUR CURRENT BALANCE:", "type" : "info", "value" : "$0.00"]]],["type" : "separator"],["type" : "icon", "value" : "autoPaySched"],["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "Auto pay scheduled for:", "type" : "info", "value" : "May 10, 2016"]]],["type" : "filler"],["orientation" : "vertical", "gravity" : "down", "type" : "itemlist", "value" : [["type" : "separator"],["label" : "Make A Payment", "type" : "button", "colorScheme" : "dark", "value" : ["type" : "LINK", "content" :["deepLink" : "payment", "deepLinkData" :["amount" : "135.20"]]]],["label" : "Talk to an Agent", "type" : "button", "colorScheme" : "light", "value" : ["type" : "LINK", "content" :["deepLink" : "call", "deepLinkData" :[]]]]]]]],
        
        "BP" : ["orientation" : "vertical", "type" : "itemlist", "value" : [["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "YOUR CURRENT BALANCE:", "type" : "info", "value" : "$201.26"]]],["type" : "separator"],["type" : "icon", "value" : "billDue"],["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "BALANCE DUE:", "type" : "info", "value" : "May 10, 2016"]]],["type" : "label", "label" : ""],["orientation" : "vertical", "type" : "itemlist", "value" : [["icon" : "", "label" : "Your Bill This Month:", "type" : "info", "value" : "$145.20"],["icon" : "", "label" : "Pending Payments:", "type" : "info", "value" : "$0.00"],["icon" : "", "label" : "Recent Payment", "type" : "info", "value" : "$34.22"]]],["label" : "* Recent transactions may take a few days to reflect on your bill.", "type" : "label"],["type" : "filler"],["orientation" : "vertical", "gravity" : "down", "type" : "itemlist", "value" : [["type" : "separator"],["label" : "Make A Payment", "type" : "button", "colorScheme" : "dark", "value" : ["type" : "LINK", "content" :["deepLink" : "payment", "deepLinkData" :["amount" : "135.20"]]]],["label" : "Talk to an Agent", "type" : "button", "colorScheme" : "light", "value" : ["type" : "LINK", "content" :["deepLink" : "call", "deepLinkData" :[]]]]]]]],
        
        "BP" : ["orientation" : "vertical", "type" : "itemlist", "value" : [["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "YOUR CURRENT BALANCE:", "type" : "info", "value" : "$201.26"]]],["type" : "separator"],["type" : "icon", "value" : "billPastDue"],["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "", "type" : "info", "value" : "$100.68", "valueColor" : "red"]]],["label" : "Please pay this amount to avoid service interruptions.", "type" : "label"],["orientation" : "vertical", "type" : "itemlist", "value" : [["icon" : "", "label" : "Your Bill This Month:", "type" : "info", "value" : "$145.20"],["icon" : "", "label" : "Pending Payments:", "type" : "info", "value" : "$0.00"],["icon" : "", "label" : "Recent Payment", "type" : "info", "value" : "$34.22"]]],["label" : "* Recent transactions may take a few days to reflect on your bill.", "type" : "label"],["type" : "filler"],["orientation" : "vertical", "gravity" : "down", "type" : "itemlist", "value" : [["type" : "separator"],["label" : "Make A Payment", "type" : "button", "colorScheme" : "dark", "value" : ["type" : "LINK", "content" :["deepLink" : "payment", "deepLinkData" :["amount" : "135.20"]]]],["label" : "Talk to an Agent", "type" : "button", "colorScheme" : "light", "value" : ["type" : "LINK", "content" :["deepLink" : "call", "deepLinkData" :[]]]]]]]],
        
        "B" : ["orientation" : "vertical", "type" : "itemlist", "value" : [["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "YOUR CURRENT BALANCE:", "type" : "info", "value" : "$201.26"]]],["type" : "separator"],["type" : "icon", "value" : "credit"],["orientation" : "horizontal", "type" : "itemlist", "value" : [["icon" : "", "label" : "", "type" : "info", "value" : "$100.68", "valueColor" : "green"]]],["label" : "Please pay this amount to avoid service interruptions.", "type" : "label"],["type" : "filler"],["orientation" : "vertical", "gravity" : "down", "type" : "itemlist", "value" : [["type" : "separator"],["label" : "Make A Payment", "type" : "button", "colorScheme" : "dark", "value" : ["type" : "LINK", "content" :["deepLink" : "payment", "deepLinkData" :["amount" : "135.20"]]]],["label" : "Talk to an Agent", "type" : "button", "colorScheme" : "light", "value" : ["type" : "LINK", "content" :["deepLink" : "call", "deepLinkData" :[]]]]]]]],
        
        "L" : [["type" : "label", "key" : "", "value" : "A VERIFICATION PIN WILL BE SENT TO YOUR PHONE NUMBER ON FILE."],["type" : "button", "key" : "Send Pin", "value" : "AID:LPRPV"]]
 
 
    ]
    **/
    /**
    
    var dataString : [String:String] = [
        "R" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"label\" : \"TROUBLESHOOTING\",\"type\" : \"label\"},{\"label\" : \"TV\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RT\"}},{\"label\" : \"INTERNET\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RI\"}},{\"label\" : \"VOICE\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RV\"}},{\"label\" : \"HOME\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RH\"}}]}",
        "RI" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"label\" : \"WHICH ONE OF THESE BEST DESCRIBES YOUR PROBLEM.\",\"type\" : \"label\"},{\"label\" : \"Connection\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RIC\"}},{\"label\" : \"Browser\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RIB\"}},{\"label\" : \"Email\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RIE\"}},{\"label\" : \"WiFi\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RIW\"}}]}",
        "RIC" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"label\" : \"Which type of Connection problem are you experiencing?\",\"type\" : \"label\"},{\"label\" : \"Intermittent\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RICI\"}},{\"label\" : \"Slow Speeds\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"RIS\"}},{\"type\" : \"separator\"},{\"type\" :\"icon\",\"value\" :\"call\"},{\"label\" : \"Or talk with our agents.\",\"type\" : \"label\"},{\"label\" : \"Schedule a Call\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}",
        "RIS" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"label\" : \"OUR TROUBLESHOOTING GUIDE CAN HELP YOU SOLVE THIS ISSUE.\",\"type\" : \"label\"},{\"label\" : \"Restart Device\",\"colorScheme\" :\"dark\",\"icon\" :\"deeplink\",\"type\" : \"button\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"troubleshoot\",\"deepLinkData\" :{\"service\" :\"internet\",\"deviceId\" :[\"123456\"]}}}},{\"label\" : \"Troubleshoot your Internet Connection\",\"colorScheme\" :\"dark\",\"icon\" :\"article\",\"type\" : \"button\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"troubleshoot\",\"deepLinkData\" :{\"service\" :\"internet\",\"deviceId\" :[\"123456\"]}}}},{\"type\" : \"separator\"},{\"type\" :\"icon\",\"value\" :\"call\"},{\"label\" : \"Or talk with our agents.\",\"type\" : \"label\"},{\"label\" : \"Schedule a Call\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}",
        "RT" : "{\"orientation\" : \"verical\",\"type\" : \"itemlist\",\"value\" : [{\"label\" : \"OUR TROUBLESHOOTING GUIDE CAN HELP YOU SOLVE THIS ISSUE.\",\"type\" : \"label\"},{\"label\" : \"Cable Issue\",\"type\" : \"button\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"troubleshoot\",\"deepLinkData\" :{\"service\" :\"video\",\"deviceId\" :[\"09876\"]}}}}]}",
        //        "B" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"Account #\",\"type\" : \"info\",\"value\" : \"728323981238921\"},{\"type\" : \"separator\"},{\"icon\" : \"icon_billing-a\",\"label\" : \"Xfinity TV\",\"type\" : \"info\",\"value\" : \"60.85\"},{\"icon\" : \"icon_billing-b\",\"label\" : \"Xfinity Internet\",\"type\" : \"info\",\"value\" : \"65.95\"},{\"icon\" : \"\",\"label\" : \"Taxes, Surcharges and Fees\",\"type\" : \"info\",\"value\" : \"8.40\"},{\"type\" : \"separator\"},{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"Total Due\",\"type\" : \"info\",\"value\" : \"$135.20\"},{\"type\" : \"separator\"},{\"icon\" : \"\",\"label\" : \"Due Date\",\"type\" : \"info\",\"value\" : \"02/26/16\"}]},{\"type\" : \"separator\"},{\"label\" : \"View Account Details\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"BBC\"}},{\"label\" : \"Understand your bill\",\"type\" : \"button\",\"value\" : {\"type\" :\"AID\",\"content\" :\"BBC\"}},{\"label\" : \"Make A Payment\",\"type\" : \"button\",\"colorScheme\" : \"dark\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"payment\",\"deepLinkData\" :{\"amount\" :\"135.20\"}}}},{\"label\" : \"Talk to an Agent\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}",
        "BP" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"YOUR CURRENT BALANCE:\",\"type\" : \"info\",\"value\" : \"$0.00\"}]},{\"type\" : \"separator\"},{\"type\" :\"icon\",\"value\" :\"billPaid\"},{\"label\" : \"No payment due. Thank you!\",\"type\" : \"label\"},{\"type\" :\"filler\"},{\"orientation\" : \"vertical\",\"gravity\" :\"down\",\"type\" : \"itemlist\",\"value\" : [{\"type\" : \"separator\"},{\"label\" : \"Make A Payment\",\"type\" : \"button\",\"colorScheme\" : \"dark\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"payment\",\"deepLinkData\" :{\"amount\" :\"135.20\"}}}},{\"label\" : \"Talk to an Agent\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}]}",
        //        "B" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"YOUR CURRENT BALANCE:\",\"type\" : \"info\",\"value\" : \"$0.00\"}]},{\"type\" : \"separator\"},{\"type\" :\"icon\",\"value\" :\"autoPaySched\"},{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"Auto pay scheduled for:\",\"type\" : \"info\",\"value\" : \"May 10, 2016\"}]},{\"type\" :\"filler\"},{\"orientation\" : \"vertical\",\"gravity\" :\"down\",\"type\" : \"itemlist\",\"value\" : [{\"type\" : \"separator\"},{\"label\" : \"Make A Payment\",\"type\" : \"button\",\"colorScheme\" : \"dark\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"payment\",\"deepLinkData\" :{\"amount\" :\"135.20\"}}}},{\"label\" : \"Talk to an Agent\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}]}",
        //        "BP" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"YOUR CURRENT BALANCE:\",\"type\" : \"info\",\"value\" : \"$201.26\"}]},{\"type\" : \"separator\"},{\"type\" :\"icon\",\"value\" :\"billDue\"},{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"BALANCE DUE:\",\"type\" : \"info\",\"value\" : \"May 10, 2016\"}]},{\"type\" :\"label\",\"label\" :\"\"},{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"Your Bill This Month:\",\"type\" : \"info\",\"value\" : \"$145.20\"},{\"icon\" : \"\",\"label\" : \"Pending Payments:\",\"type\" : \"info\",\"value\" : \"$0.00\"},{\"icon\" : \"\",\"label\" : \"Recent Payment\",\"type\" : \"info\",\"value\" : \"$34.22\"}]},{\"label\" : \"* Recent transactions may take a few days to reflect on your bill.\",\"type\" : \"label\"},{\"type\" :\"filler\"},{\"orientation\" : \"vertical\",\"gravity\" :\"down\",\"type\" : \"itemlist\",\"value\" : [{\"type\" : \"separator\"},{\"label\" : \"Make A Payment\",\"type\" : \"button\",\"colorScheme\" : \"dark\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"payment\",\"deepLinkData\" :{\"amount\" :\"135.20\"}}}},{\"label\" : \"Talk to an Agent\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}]}",
        //        "BP" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"YOUR CURRENT BALANCE:\",\"type\" : \"info\",\"value\" : \"$201.26\"}]},{\"type\" : \"separator\"},{\"type\" :\"icon\",\"value\" :\"billPastDue\"},{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"\",\"type\" : \"info\",\"value\" : \"$100.68\",\"valueColor\" :\"red\"}]},{\"label\" : \"Please pay this amount to avoid service interruptions.\",\"type\" : \"label\"},{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"Your Bill This Month:\",\"type\" : \"info\",\"value\" : \"$145.20\"},{\"icon\" : \"\",\"label\" : \"Pending Payments:\",\"type\" : \"info\",\"value\" : \"$0.00\"},{\"icon\" : \"\",\"label\" : \"Recent Payment\",\"type\" : \"info\",\"value\" : \"$34.22\"}]},{\"label\" : \"* Recent transactions may take a few days to reflect on your bill.\",\"type\" : \"label\"},{\"type\" :\"filler\"},{\"orientation\" : \"vertical\",\"gravity\" :\"down\",\"type\" : \"itemlist\",\"value\" : [{\"type\" : \"separator\"},{\"label\" : \"Make A Payment\",\"type\" : \"button\",\"colorScheme\" : \"dark\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"payment\",\"deepLinkData\" :{\"amount\" :\"135.20\"}}}},{\"label\" : \"Talk to an Agent\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}]}",
        //        "B" : "{\"orientation\" : \"vertical\",\"type\" : \"itemlist\",\"value\" : [{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"YOUR CURRENT BALANCE:\",\"type\" : \"info\",\"value\" : \"$201.26\"}]},{\"type\" : \"separator\"},{\"type\" :\"icon\",\"value\" :\"credit\"},{\"orientation\" : \"horizontal\",\"type\" : \"itemlist\",\"value\" : [{\"icon\" : \"\",\"label\" : \"\",\"type\" : \"info\",\"value\" : \"$100.68\",\"valueColor\" :\"green\"}]},{\"label\" : \"Please pay this amount to avoid service interruptions.\",\"type\" : \"label\"},{\"type\" :\"filler\"},{\"orientation\" : \"vertical\",\"gravity\" :\"down\",\"type\" : \"itemlist\",\"value\" : [{\"type\" : \"separator\"},{\"label\" : \"Make A Payment\",\"type\" : \"button\",\"colorScheme\" : \"dark\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"payment\",\"deepLinkData\" :{\"amount\" :\"135.20\"}}}},{\"label\" : \"Talk to an Agent\",\"type\" : \"button\",\"colorScheme\" : \"light\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"call\",\"deepLinkData\" :{}}}}]}]}",
        "O" : "{\"orientation\" : \"verical\",\"type\" : \"itemlist\",\"value\" : [{\"label\" : \"TALK WITH OUR AGENTS.\",\"type\" : \"label\"},{\"label\" : \"1-800-934-6489\",\"type\" : \"button\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"dial\",\"deepLinkData\" :{\"phone\" :\"1-800-934-6489\"}}}}]}",
        "L" : "{\"orientation\" : \"verical\",\"type\" : \"itemlist\",\"value\" : [{\"label\" : \"A VERIFICATION PIN WILL BE SENT TO YOUR PHONE NUMBER ON FILE.\",\"type\" : \"label\"},{\"label\" : \"Send Pin\",\"type\" : \"button\",\"value\" : {\"type\" :\"LINK\",\"content\" :{\"deepLink\" :\"modifyUserPassword\",\"deepLinkData\" :{}}}}]}",
        // "L" : "[{\"type\" : \"label\",\"key\" : \"\",\"value\" : \"A VERIFICATION PIN WILL BE SENT TO YOUR PHONE NUMBER ON FILE.\"},{\"type\" : \"button\",\"key\" : \"Send Pin\",\"value\" : \"AID:LPRPV\"}]",
        "LPRPV" : "[{\"type\" : \"label\",\"key\" : \"\",\"value\" : \"Type your pin below\"},{\"type\" : \"pin\",\"key\" : \"\",\"value\" : \"\"},{\"type\" : \"button\",\"key\" : \"Verify\",\"value\" : \"AID:LPRPVNP\"}]",
        "LPRPVNP" : "[{\"type\" : \"label\",\"key\" : \"\",\"value\" : \"Enter your new password\"},{\"type\" : \"textfield\",\"key\" : \"\",\"value\" : \"\"},{\"type\" : \"button\",\"key\" : \"Continue\",\"value\" : \"AID:LPRPVNPC\"}]",
        "LPRPVNPC" : "[{\"type\" : \"label\",\"key\" : \"\",\"value\" : \"Please re-enter the password\"},{\"type\" : \"textfield\",\"key\" : \"\",\"value\" : \"\"},{\"type\" : \"button\",\"key\" : \"Set new password\",\"value\" : \"AID:LPRPVNPCC\"}]",
        "LPRPVNPCC" : "[{\"type\" : \"label\",\"key\" : \"\",\"value\" : \"Password changed\"}]"
    ]
    
    **/
}


