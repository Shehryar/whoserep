//
//  HTTPClientSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 12/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class MockURLSession: URLSessionProtocol {
    private(set) var lastRequest: URLRequest?
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextError: Error?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        lastRequest = request
        if let url = request.url {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
            completionHandler(nextData, response, nextError)
        }
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private(set) var resumeWasCalled = false
    
    override func resume() {
        resumeWasCalled = true
    }
}

class HTTPClientSpec: QuickSpec {
    override func spec() {
        describe("HTTPClient") {
            let clientTypeQueryItem = URLQueryItem(name: ASAPP.clientTypeKey, value: ASAPP.clientType)
            let clientVersionQueryItem = URLQueryItem(name: ASAPP.clientVersionKey, value: ASAPP.clientVersion)
            
            context(".sendRequest(...)") {
                /*
                 NB: To test the early return due to makeRequest(...) returning nil, you have to find a URL string
                 that's valid according to RFC 1808 but invalid according to RFC 3986. Good luck!
                 */
                
                context("with a URL") {
                    it("GETs the provided URL") {
                        let urlSession = MockURLSession()
                        let task = MockURLSessionDataTask()
                        urlSession.nextDataTask = task
                        let subject = HTTPClient(urlSession: urlSession)
                        let url = URL(string: "http://example.com/")!
                        subject.sendRequest(url: url, completion: { (_, _, _) in })
                        let urlComponents = URLComponents(string: urlSession.lastRequest!.url!.absoluteString)
                        expect(urlComponents?.scheme).to(equal("http"))
                        expect(urlComponents?.host).to(equal("example.com"))
                        expect(Set(urlComponents!.queryItems!)).to(equal(Set([clientTypeQueryItem, clientVersionQueryItem])))
                        expect(urlSession.lastRequest?.httpMethod).to(equal(HTTPMethod.POST.rawValue))
                        expect(task.resumeWasCalled).to(equal(true))
                    }
                }
                
                context("with invalid GET parameters") {
                    it("GETs the provided URL, ignoring the invalid parameters") {
                        let urlSession = MockURLSession()
                        let subject = HTTPClient(urlSession: urlSession)
                        let url = URL(string: "http://example.com/")!
                        subject.sendRequest(url: url, params: ["foo": 9001], completion: { (_, _, _) in })
                        let urlComponents = URLComponents(string: urlSession.lastRequest!.url!.absoluteString)
                        expect(urlComponents?.scheme).to(equal("http"))
                        expect(urlComponents?.host).to(equal("example.com"))
                        expect(Set(urlComponents!.queryItems!)).to(equal(Set([clientTypeQueryItem, clientVersionQueryItem])))
                    }
                }
                
                context("with GET parameters") {
                    it("GETs the provided URL with the query parameters") {
                        let urlSession = MockURLSession()
                        let subject = HTTPClient(urlSession: urlSession)
                        let url = URL(string: "http://example.com/")!
                        subject.sendRequest(method: .GET, url: url, params: ["foo": "9001", "bar": "9002"], completion: { (_, _, _) in })
                        let urlComponents = URLComponents(string: urlSession.lastRequest!.url!.absoluteString)
                        expect(urlComponents?.scheme).to(equal("http"))
                        expect(urlComponents?.host).to(equal("example.com"))
                        expect(Set(urlComponents!.queryItems!)).to(equal(Set([clientTypeQueryItem, clientVersionQueryItem, URLQueryItem(name: "foo", value: "9001"), URLQueryItem(name: "bar", value: "9002")])))
                    }
                }
                
                context("with the POST method") {
                    it("it puts the parameters in the httpBody") {
                        let urlSession = MockURLSession()
                        let subject = HTTPClient(urlSession: urlSession)
                        let url = URL(string: "http://example.com/")!
                        subject.sendRequest(method: .POST, url: url, params: ["foo": 9001], completion: { (_, _, _) in })
                        let urlComponents = URLComponents(string: urlSession.lastRequest!.url!.absoluteString)
                        expect(urlComponents?.scheme).to(equal("http"))
                        expect(urlComponents?.host).to(equal("example.com"))
                        expect(Set(urlComponents!.queryItems!)).to(equal(Set([clientTypeQueryItem, clientVersionQueryItem])))
                        expect(urlSession.lastRequest?.httpBody).toNot(beNil())
                        let body = urlSession.lastRequest!.httpBody!
                        let dict = try? JSONSerialization.jsonObject(with: body, options: []) as! [String: Any]
                        expect((dict?["params"] as? [String: Any] ?? [:])["foo"] as? Int).to(equal(9001))
                    }
                }
                
                context("with an unexpected kind of response data") {
                    it("calls the completion handler with nil data") {
                        let urlSession = MockURLSession()
                        urlSession.nextData = "foo".data(using: .utf8)
                        let subject = HTTPClient(urlSession: urlSession)
                        let url = URL(string: "http://example.com/")!
                        var dict: [String: Any]? = [:]
                        subject.sendRequest(url: url, completion: { (data, _, _) in
                            dict = data
                        })
                        expect(dict).toEventually(beNil())
                        let urlComponents = URLComponents(string: urlSession.lastRequest!.url!.absoluteString)
                        expect(urlComponents?.scheme).to(equal("http"))
                        expect(urlComponents?.host).to(equal("example.com"))
                        expect(Set(urlComponents!.queryItems!)).to(equal(Set([clientTypeQueryItem, clientVersionQueryItem])))
                    }
                }
                
                context("with response data") {
                    it("calls the completion handler with the data") {
                        let urlSession = MockURLSession()
                        urlSession.nextData = "{\"foo\": \"bar\"}".data(using: .utf8)
                        let subject = HTTPClient(urlSession: urlSession)
                        let url = URL(string: "http://example.com/")!
                        var dict: [String: Any]? = [:]
                        subject.sendRequest(url: url, completion: { (data, _, _) in
                            dict = data
                        })
                        expect(dict as? [String: String]).toEventually(equal(["foo": "bar"]))
                        let urlComponents = URLComponents(string: urlSession.lastRequest!.url!.absoluteString)
                        expect(urlComponents?.scheme).to(equal("http"))
                        expect(urlComponents?.host).to(equal("example.com"))
                        expect(Set(urlComponents!.queryItems!)).to(equal(Set([clientTypeQueryItem, clientVersionQueryItem])))
                    }
                }
                
                context("with custom headers") {
                    it("GETs the provided URL with the custom headers") {
                        let urlSession = MockURLSession()
                        let subject = HTTPClient(urlSession: urlSession)
                        let url = URL(string: "http://example.com/")!
                        subject.sendRequest(url: url, headers: ["foo": "bar", "baz": "alpha"], completion: { (_, _, _) in })
                        let urlComponents = URLComponents(string: urlSession.lastRequest!.url!.absoluteString)
                        expect(urlComponents?.scheme).to(equal("http"))
                        expect(urlComponents?.host).to(equal("example.com"))
                        expect(Set(urlComponents!.queryItems!)).to(equal(Set([clientTypeQueryItem, clientVersionQueryItem])))
                        expect(urlSession.lastRequest?.allHTTPHeaderFields?["foo"]).to(equal("bar"))
                        expect(urlSession.lastRequest?.allHTTPHeaderFields?["baz"]).to(equal("alpha"))
                    }
                }
            }
        }
    }
}
