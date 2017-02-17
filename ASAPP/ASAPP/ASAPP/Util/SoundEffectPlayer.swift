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
        
        static let all: [Sound] = [
            liveChatNotification
        ]
    }
    
    private var systemSoundIds = [Sound : SystemSoundID]()
    
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
            break
        }
        
        var soundId: SystemSoundID = 0
        
        if let fileName = fileName, let fileExtension = fileExtension,
            let soundURL = ASAPPBundle.url(forResource: fileName, withExtension: fileExtension) {
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
            DebugLogError("Unable to play sound: \(sound)")
        }
    }
}
