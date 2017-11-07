//
//  OutgoingMessageSerializerSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/30/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class OutgoingMessageSerializerSpec: QuickSpec {
    override func spec() {
        describe("OutgoingMessageSerializer") {
            describe(".createAuthRequest()") {
                context("with a config with the default region code") {
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
                    ASAPP.initialize(with: config)
                    ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: {
                        return [:]
                    }, userLoginHandler: { _ in })
                    
                    it("creates an auth request with the default region code") {
                        let serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        let authRequest = serializer.createAuthRequest()
                        expect(authRequest.params["RegionCode"] as? String).to(equal("US"))
                    }
                }
                
                context("with a config with a custom region code") {
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test", regionCode: "AUS")
                    ASAPP.initialize(with: config)
                    ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: {
                        return [:]
                    }, userLoginHandler: { _ in })
                    
                    it("creates an auth request with the custom region code") {
                        let serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        let authRequest = serializer.createAuthRequest()
                        expect(authRequest.params["RegionCode"] as? String).to(equal("AUS"))
                    }
                }
            }
        }
    }
}
