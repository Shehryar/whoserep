//
//  ASAPPDevice.swift
//  ASAPP
//
//  Created by Shehryar Hussain on 1/16/19.
//  Copyright © 2019 asappinc. All rights reserved.
//

import Foundation

struct PushNotificationRecipient: Codable, Equatable {
    let userId: String
    let registeredId: String // Equivalent to either APNS token or UUID that was registered
    let assignedId: Int // Id returned from ASAPP to identify the device
}
