//
//  Images.swift
//  Tests
//
//  Created by Hans Hyttinen on 11/16/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Foundation
import UIKit
@testable import ASAPP
import Quick
import Nimble
import FBSnapshotTestCase
import Nimble_Snapshots

class Images: QuickSpec {
    let specName = "Images"
    let jsonSuffix = ".json"
    let isValid = "isValid"
    
    override func spec() {
        var toRecord: [String] = []
        var toValidate: [String] = []
        
        func getNameFromPath(_ path: String, removing suffix: String) -> String {
            return String(NSString(string: path).lastPathComponent.dropLast(suffix.count))
        }
        
        let dir = TestUtil.getBundle().object(forInfoDictionaryKey: "LAYOUT_SNAPSHOTS_DIR") as! String
        FBSnapshotTest.setReferenceImagesDirectory(dir)
        let imageDir = URL(fileURLWithPath: dir, isDirectory: true).appendingPathComponent(specName, isDirectory: true).path
        
        // swiftlint:disable:next force_try
        let files = try! FileManager.default.contentsOfDirectory(atPath: dir).map { URL(fileURLWithPath: dir, isDirectory: true).appendingPathComponent($0, isDirectory: false) }
        let jsonFiles = files.filter { $0.absoluteString.hasSuffix(self.jsonSuffix) }
        
        if let snapshotFiles = try? FileManager.default.contentsOfDirectory(atPath: imageDir) {
            let pngSuffix = "@2x.png"
            let snapshotNames = snapshotFiles.map { getNameFromPath($0, removing: pngSuffix) }
            
            for jsonFile in jsonFiles {
                let fileName = jsonFile.path
                let layoutName = getNameFromPath(fileName, removing: jsonSuffix).replacingOccurrences(of: "-", with: "_")
                if snapshotNames.contains(layoutName) {
                    toValidate.append(fileName)
                } else {
                    toRecord.append(fileName)
                }
            }
        } else {
            toRecord = jsonFiles.map { $0.path }
        }
        
        beforeSuite {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            TestUtil.setUpASAPP()
            
            ASAPP.strings = ASAPPStrings()
            ASAPP.styles = ASAPPStyles()
        }
        
        func getViewForPath(_ path: String) -> UIView {
            let dict = TestUtil.dictForFile(at: path)
            if let container = ComponentViewContainer.from(dict) {
                let viewController = ComponentViewController()
                viewController.componentViewContainer = container
                viewController.updateFrames()
                if let scrollView = viewController.rootView as? ScrollView {
                    return scrollView.contentView!.view
                }
                return viewController.view
            } else {
                let singleMessage = SingleMessageViewController()
                singleMessage.showMessage(at: path)
                return singleMessage.view
            }
        }
        
        func recordSnapshots(_ paths: [String]) {
            for path in paths {
                it(getNameFromPath(path, removing: jsonSuffix)) {
                    expect(getViewForPath(path)).to(recordSnapshot())
                }
            }
        }
        
        func checkSnapshots(_ paths: [String]) {
            for path in paths {
                it(getNameFromPath(path, removing: jsonSuffix)) {
                    expect(getViewForPath(path)).to(haveValidSnapshot())
                }
            }
        }
        
        recordSnapshots(toRecord)
        checkSnapshots(toValidate)
    }
}
