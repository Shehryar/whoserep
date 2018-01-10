//
//  HTTPClient.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

class HTTPClient: NSObject {
    
    typealias CompletionHandler = ([String: Any]?, URLResponse?, Error?) -> Void
    
    static let shared = HTTPClient()
    
    var defaultHeaders: [String: String]?
    
    private let urlSession: URLSessionProtocol
    
    required init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: Sending Requests
    
    func sendRequest(method: HTTPMethod = .GET,
                     url: URL,
                     headers: [String: String]? = nil,
                     params: [String: Any]? = nil,
                     completion: @escaping CompletionHandler) {
        guard let requestURL = makeRequestURL(method: method, url: url, params: params) else {
            DebugLog.w(caller: self, "Failed to construct requestURL.")
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        
        request.injectHeaders(defaultHeaders)
        request.injectHeaders(headers)
        
        if [HTTPMethod.POST].contains(method), let params = params {
            request.httpBody = JSONUtil.getDataFrom(params)
        }
       
        if ASAPP.debugLogLevel.rawValue >= ASAPPLogLevel.debug.rawValue {
            let headersString = JSONUtil.stringify(request.allHTTPHeaderFields) ?? ""
            let paramsString = JSONUtil.stringify(params, prettyPrinted: true) ?? ""
            DebugLog.d(caller: HTTPClient.self,
                       "Sending HTTP Request \(method): \(url)\n  Headers: \(headersString)\n  Params: \(paramsString)\n")
        }
        
        urlSession.dataTask(with: request) { (data, response, error) in
            var jsonMap: [String: Any]?
            let jsonObject = JSONUtil.getObjectFrom(data)
            
            if let jsonObject = jsonObject as? [String: Any] {
                jsonMap = jsonObject
            }
            
            if jsonMap == nil {
                DebugLog.w(caller: HTTPClient.self, "Response data has unexpected type: \(jsonObject ?? "nil")")
            }
            
            completion(jsonMap, response, error)
        }.resume()
    }
}

// MARK: - URL

extension HTTPClient {
    
    private func makeRequestURL(method: HTTPMethod, url: URL, params: [String: Any]?) -> URL? {
        var urlComponents = URLComponents(string: url.absoluteString)
        if [HTTPMethod.GET].contains(method), let params = params {
            var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
            for (name, value) in params {
                guard let valueString = value as? String else {
                    DebugLog.w(caller: self, "Unable to set parameter (\(name) : \(value)). All values on a GET request must be of type String.")
                    continue
                }
                
                let queryItem = URLQueryItem(name: name, value: valueString)
                queryItems.append(queryItem)
            }
            urlComponents?.queryItems = queryItems
        }
        
        return urlComponents?.url
    }
}

// MARK: - HEADERS

extension URLRequest {
    
    mutating func injectHeaders(_ headers: [String: String]?) {
        guard let headers = headers else {
            return
        }
        
        for (field, value) in headers {
            setValue(value, forHTTPHeaderField: field)
        }
    }
}
