//
//  CensorSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 6/22/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import ASAPP

class CensorSpec: QuickSpec {
    func testAllCasesInFile(named name: String, using censor: Censor) {
        let dict = TestUtil.dictForFile(named: name)!
        let cases = dict["cases"] as! [[String: Any]]
        for testCase in cases {
            let name = testCase["name"] as! String
            let input = testCase["input"] as! String
            let expectedOutput = testCase["expected"] as! String
            print("Censor test case: \(name)\n\tInput: \(input)")
            let output = censor.process(input)
            expect(output).to(equal(expectedOutput))
        }
    }
    
    override func spec() {
        describe("Censor") {
            describe(".process(_:)") {
                
                context("email") {
                    let censor = Censor()
                    
                    beforeSuite {
                        censor.rules = [Censor.Rule(
                            type: .message,
                            category: "email",
                            search: Censor.Rule.Search(regexes: ["/\\b[^\\s@]+@([a-z0-9-]+(com|net|gov|edu|(\\.[a-z0-9-]+)+)|hotmail|gmail|yahoo|verizon|outlook|inbox|icloud|live|comcast)\\b/"]),
                            replacements: [
                                Censor.Rule.Replacement(search: "/\\d/", replace: "#"),
                                Censor.Rule.Replacement(search: "/[a-z]/", replace: "X")
                            ]
                        )]
                    }
                    
                    it("passes all test cases") {
                        self.testAllCasesInFile(named: "censor-email", using: censor)
                    }
                }
                
                context("date") {
                    let censor = Censor()
                    
                    beforeSuite {
                        censor.rules = [Censor.Rule(
                            type: .message,
                            category: "date",
                            search: Censor.Rule.Search(regexes: [
                                "\\b(([0-1]?[0-9])|(Jan(\\.|uary)?|Feb(\\.|ruary)?|Mar(\\.|ch)?|Apr(\\.|il)?|May|Jun(\\.|e)?|Jul(\\.|y)?|Aug(\\.|ust)?|Sep(\\.|t(\\.|ember)?)?|Oct(\\.|ober)?|Nov(\\.|ember)?|Dec(\\.|ember)?)|(ene(\\.|ro)?|feb(\\.|rero)?|mar(\\.|zo)?|abr(\\.|il)?|may(\\.|o)?|jun(\\.|io)?|jul(\\.|io)?|ago(\\.|sto)?|sep(\\.|t(\\.|iembre)?)?|set(\\.|iembre)?|oct(\\.|ubre)?|nov(\\.|iembre)?|dic(\\.|iembre)?))(\\s*(\\s+|[.\\/-])\\s*)([0-3]?[0-9]((st|nd|rd|th),?)?)((\\s*(\\s+|[.\\/-])\\s*)|(\\s+(in|of|del?)\\s+)|,\\s+)(\\d{4}|\\d{2})\\b"
                            ]),
                            replacements: [
                                Censor.Rule.Replacement(search: "\\d", replace: "#"),
                                Censor.Rule.Replacement(search: "/[a-z]/", replace: "X")
                            ]
                        )]
                    }
                    
                    it("passes all test cases") {
                        self.testAllCasesInFile(named: "censor-date", using: censor)
                    }
                }
                
                context("password") {
                    let censor = Censor()
                    
                    beforeSuite {
                        censor.rules = [Censor.Rule(
                            type: .message,
                            category: "password",
                            search: Censor.Rule.Search(regexes: [
                                "/^[\\s\\S]*\\b(use?r ?(id|name)|pin|pa?ss(code|wo?rd))\\b[\\s\\S]*$/",
                                "[^a-z\\s]+"
                            ]),
                            replacements: [
                                Censor.Rule.Replacement(search: "[^a-z0-9\\s#]", replace: "*"),
                                Censor.Rule.Replacement(search: "/[0-9]/", replace: "#")
                            ]
                        )]
                    }
                    
                    it("passes all test cases") {
                        self.testAllCasesInFile(named: "censor-password", using: censor)
                    }
                }
                
                context("regex chain with early failure") {
                    let censor = Censor()
                    
                    beforeSuite {
                        censor.rules = [Censor.Rule(
                            type: .message,
                            category: "password",
                            search: Censor.Rule.Search(regexes: [
                                "/^[\\s\\S]*\\b(use?r ?(id|name))\\b[\\s\\S]*$/",
                                "[^a-z\\s]+"
                            ]),
                            replacements: [
                                Censor.Rule.Replacement(search: "[^a-z0-9\\s#]", replace: "*"),
                                Censor.Rule.Replacement(search: "/[0-9]/", replace: "#")
                            ]
                        )]
                    }
                    
                    it("fails to redact if chain fails early") {
                        let name = "Early failure in regex chain"
                        let input = "My password is hunter2"
                        let expectedOutput = input
                        print("Censor test case: \(name)\n\tInput: \(input)")
                        let output = censor.process(input)
                        expect(output).to(equal(expectedOutput))
                    }
                }
                
                context("regex chain with early failure and fragment digit scrubbing") {
                    let censor = Censor()
                    
                    beforeSuite {
                        censor.rules = [
                            Censor.Rule(
                                type: .message,
                                category: "password",
                                search: Censor.Rule.Search(regexes: [
                                    "/^[\\s\\S]*\\b(name)\\b[\\s\\S]*$/",
                                    "[^a-z\\s]+"
                                ]),
                                replacements: [
                                    Censor.Rule.Replacement(search: "[^a-z0-9\\s#]", replace: "*"),
                                    Censor.Rule.Replacement(search: "/[0-9]/", replace: "#")
                                ]
                            ),
                            Censor.Rule(
                                type: .fragment,
                                category: "digits",
                                search: Censor.Rule.Search(regexes: [
                                    "[0-9]+"
                                ]),
                                replacements: [Censor.Rule.Replacement(
                                    search: "[0-9]+",
                                    replace: "#"
                                )]
                            )
                        ]
                    }
                    
                    it("still redacts digits after an early failure") {
                        let name = "Redaction of digits for fragments"
                        let input = "My password is hunter2"
                        let expectedOutput = "My password is hunter{digits:#}"
                        print("Censor test case: \(name)\n\tInput: \(input)")
                        let output = censor.process(input, type: .fragment)
                        expect(output).to(equal(expectedOutput))
                    }
                }
                
                context("replacement search that doesn't match the search results") {
                    let censor = Censor()
                    
                    beforeSuite {
                        censor.rules = [Censor.Rule(
                            type: .message,
                            category: "password",
                            search: Censor.Rule.Search(regexes: [
                                "/^[\\s\\S]*\\b(password)\\b[\\s\\S]*$/",
                                "[^a-z\\s]+"
                            ]),
                            replacements: [
                                Censor.Rule.Replacement(search: "[s-z]", replace: "*")
                            ]
                        )]
                    }
                    
                    it("leaves unmatched parts untagged") {
                        let name = "Prevent unnecessary tagging"
                        let input = "My password is hunter2"
                        let expectedOutput = input
                        print("Censor test case: \(name)\n\tInput: \(input)")
                        let output = censor.process(input)
                        expect(output).to(equal(expectedOutput))
                    }
                }
                
                context("7 digits") {
                    let censor = Censor()
                    
                    beforeSuite {
                        censor.rules = [Censor.Rule(
                            type: .message,
                            category: "digits7",
                            search: Censor.Rule.Search(regexes: [
                                "([0-9][\\s./-]*)*[0-9]",
                                "^([0-9][\\s./-]*){6}[0-9]$"
                            ]),
                            replacements: [
                                Censor.Rule.Replacement(search: "/[0-9]/", replace: "#")
                            ]
                        )]
                    }
                    
                    it("passes all test cases") {
                        self.testAllCasesInFile(named: "censor-digits7", using: censor)
                    }
                }
            }
        }
    }
}
