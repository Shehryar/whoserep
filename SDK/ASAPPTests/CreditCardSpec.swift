//
//  CreditCardSpec.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class CreditCardSpec: QuickSpec {
    override func spec() {
        describe("CreditCard") {
            describe(".getExpiryComponents()") {
                var card: CreditCard!
                
                context("when all properties are valid") {
                    beforeEach {
                        card = CreditCard(name: "Joe Public", number: "", expiry: "99/99", cvv: "000")
                    }
                    
                    it("returns the month and the year") {
                        let expected = (99, 99)
                        let actual = card.getExpiryComponents()
                        expect(actual).toNot(beNil())
                        expect(actual!.0).to(equal(expected.0))
                        expect(actual!.1).to(equal(expected.1))
                    }
                }
                
                context("when all properties are nil") {
                    beforeEach {
                        card = CreditCard(name: nil, number: nil, expiry: nil, cvv: nil)
                    }
                    
                    it("returns nil") {
                        expect(card.getExpiryComponents()).to(beNil())
                    }
                }
            }
            
            describe(".getInvalidFields()") {
                var validCard: CreditCard {
                    return CreditCard(name: "Joe Public", number: "1111222233334444", expiry: "12/12", cvv: "123")
                }
                var card: CreditCard!
                var result: [CreditCardField]?
                let allFields: [CreditCardField] = [.name, .number, .expiry, .cvv]
                
                context("when all properties are valid") {
                    beforeEach {
                        card = validCard
                        result = card.getInvalidFields()
                    }
                    
                    it("returns nil") {
                        expect(result).to(beNil())
                    }
                }
                
                context("when all properties are nil") {
                    beforeEach {
                        card = CreditCard(name: nil, number: nil, expiry: nil, cvv: nil)
                        result = card.getInvalidFields()
                    }
                    
                    it("returns all fields") {
                        expect(result).toNot(beNil())
                        expect(result).to(contain(allFields))
                    }
                }
                
                context("when all properties are empty") {
                    beforeEach {
                        card = CreditCard(name: "", number: "", expiry: "", cvv: "")
                        result = card.getInvalidFields()
                    }
                    
                    it("returns all fields") {
                        expect(result).toNot(beNil())
                        expect(result).to(contain(allFields))
                    }
                }
                
                context("when the number is shorter than 13 digits") {
                    beforeEach {
                        card = validCard
                        card.number = "1"
                        result = card.getInvalidFields()
                    }
                    
                    it("returns the number field") {
                        expect(result).toNot(beNil())
                        expect(result).to(equal([.number]))
                    }
                }
                
                context("when the number is longer than 19 digits") {
                    beforeEach {
                        card = validCard
                        card.number = "12345678901234567890"
                        result = card.getInvalidFields()
                    }
                    
                    it("returns the number field") {
                        expect(result).toNot(beNil())
                        expect(result).to(equal([.number]))
                    }
                }
                
                context("when the expiry month is less than 1") {
                    beforeEach {
                        card = validCard
                        card.expiry = "0/12"
                        result = card.getInvalidFields()
                    }
                    
                    it("returns the expiry field") {
                        expect(result).toNot(beNil())
                        expect(result).to(equal([.expiry]))
                    }
                }
                
                context("when the expiry month is greater than 12") {
                    beforeEach {
                        card = validCard
                        card.expiry = "13/12"
                        result = card.getInvalidFields()
                    }
                    
                    it("returns the expiry field") {
                        expect(result).toNot(beNil())
                        expect(result).to(equal([.expiry]))
                    }
                }
                
                context("when the CVV is shorter than 3 digits") {
                    beforeEach {
                        card = validCard
                        card.cvv = "12"
                        result = card.getInvalidFields()
                    }
                    
                    it("returns the cvv field") {
                        expect(result).toNot(beNil())
                        expect(result).to(equal([.cvv]))
                    }
                }
            }
        }
    }
}
