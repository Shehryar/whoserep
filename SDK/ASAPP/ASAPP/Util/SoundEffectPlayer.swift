//
//  SoundEffectPlayer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import AudioToolbox

class SoundEffectPlayer: NSObject {

    enum Sound: SystemSoundID {
        case liveChatNotification
        case wow1
        case wow2
        case wow3
        case wow4
        case wow5
        
        static let all: [Sound] = [
            liveChatNotification,
            wow1,
            wow2,
            wow3,
            wow4,
            wow5
        ]
    }
    
    private var systemSoundIds = [Sound: SystemSoundID]()
    
    deinit {
        for (_, soundId) in systemSoundIds {
            AudioServicesDisposeSystemSoundID(soundId)
        }
    }
    
    // MARK:- Playing a Sound
    
    private func getSystemSoundId(for sound: Sound) -> SystemSoundID? {
        if let systemSoundId = systemSoundIds[sound] {
            return systemSoundId
        }
        
        var fileName: String?
        var fileExtension: String?
        
        switch sound {
        case .liveChatNotification:
            fileName = "chat-notification"
            fileExtension = "wav"
            
        case .wow1:
            fileName = "wow-1"
            fileExtension = "wav"
            
        case .wow2:
            fileName = "wow-2"
            fileExtension = "wav"
            
        case .wow3:
            fileName = "wow-3"
            fileExtension = "wav"
            
        case .wow4:
            fileName = "wow-4"
            fileExtension = "wav"
            
        case .wow5:
            fileName = "wow-5"
            fileExtension = "wav"
        }
        
        var soundId: SystemSoundID = 0
        
        if let fileName = fileName, let fileExtension = fileExtension,
            let soundURL = ASAPP.bundle.url(forResource: fileName, withExtension: fileExtension) {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundId)
            systemSoundIds[sound] = soundId
            
            return soundId
        }

        return nil
    }
    
    func playSound(_ sound: Sound) {
        if let soundId = getSystemSoundId(for: sound) {
            if #available(iOS 9.0, *) {
                AudioServicesPlaySystemSoundWithCompletion(soundId, {
                    
                })
            } else {
                AudioServicesPlaySystemSound(soundId)
            }
        } else {
            DebugLog.e("Unable to play sound: \(sound)")
        }
    }
}
