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

protocol HTTPClientProtocol: class {
    var session: Session? { get set }
    
    func config(_ config: ASAPPConfig)
    // swiftlint:disable:next function_parameter_count
    func sendRequest(method: HTTPMethod, path: String, headers: [String: String]?, params: [String: Any]?, data: Data?, completion: @escaping HTTPClient.DataCompletionHandler)
    func sendRequest(method: HTTPMethod, path: String, headers: [String: String]?, params: [String: Any]?, completion: @escaping HTTPClient.DictCompletionHandler)
}

extension HTTPClientProtocol {
    func sendRequest(
        method: HTTPMethod = .POST,
        path: String,
        headers: [String: String]? = nil,
        params: [String: Any]? = nil,
        data: Data? = nil,
        completion: @escaping HTTPClient.DataCompletionHandler) {
        return sendRequest(method: method, path: path, headers: headers, params: params, data: data, completion: completion)
    }
    
    func sendRequest(
        method: HTTPMethod = .GET,
        path: String,
        headers: [String: String]? = nil,
        params: [String: Any]? = nil,
        completion: @escaping HTTPClient.DictCompletionHandler) {
        return sendRequest(method: method, path: path, headers: headers, params: params, completion: completion)
    }
}

class HTTPClient: NSObject, HTTPClientProtocol {
    typealias DictCompletionHandler = ([String: Any]?, URLResponse?, Error?) -> Void
    typealias DataCompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    static let shared = HTTPClient()
    
    var defaultHeaders: [String: String] = [:]
    
    var session: Session?
    
    private let urlSession: URLSessionProtocol
    
    private var baseUrl = URL(string: "")
    
    required init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    static let defaultParams: [String: String] = [
        ASAPP.clientTypeKey: ASAPP.clientType,
        ASAPP.clientVersionKey: ASAPP.clientVersion
    ]
    
    func config(_ config: ASAPPConfig) {
        baseUrl = URL(string: "https://\(config.apiHostName)/api/http/v1/")
        defaultHeaders[ASAPP.clientTypeKey] = ASAPP.clientType
        defaultHeaders[ASAPP.clientVersionKey] = ASAPP.clientVersion
        defaultHeaders[ASAPP.clientSecretKey] = config.clientSecret
    }
    
    func getHeaders(for session: Session) -> [String: String]? {
        let passwordPayloadString = session.sessionTokenForHTTP
        
        let authPayloadString = ":\(passwordPayloadString)"
        guard let authPayloadData = authPayloadString.data(using: .utf8) else {
            DebugLog.e(caller: self, "Could not serialize the authentication payload.")
            return nil
        }
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Basic \(authPayloadData.base64EncodedString())"
        ]
        
        return headers
    }
    
    func getContext(for session: Session?) -> [String: Any] {
        return ["CompanyId": session?.company.id ?? 0]
    }
    
    // MARK: Sending Requests
    
    private func createRequest(method: HTTPMethod, url: URL, headers: [String: String]?, params: [String: Any]?, context: [String: Any]? = nil, data: Data? = nil) -> URLRequest? {
        var urlParams = HTTPClient.defaultParams
        if method == .GET {
            if let stringyParams = params as? [String: String] {
                urlParams.add(stringyParams)
            } else if params != nil {
                DebugLog.w(caller: self, "GET params must be String values: \(String(describing: params))")
            }
        }
        
        guard let requestURL = makeRequestURL(url: url, params: urlParams) else {
            DebugLog.w(caller: self, "Failed to construct requestURL.")
            return nil
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        
        request.injectHeaders(defaultHeaders)
        if let session = session {
            request.injectHeaders(getHeaders(for: session))
        }
        request.injectHeaders(headers)
        
        if method != .GET,
           let params = params {
            var dict = [
                "params": params,
                "ctxParams": context ?? getContext(for: session)
            ] as [String: Any]
            if let data = data {
                dict["binaryBase64"] = data.base64EncodedString()
            }
            request.httpBody = JSONUtil.getDataFrom(dict)
        }
        
        if ASAPP.debugLogLevel.rawValue >= ASAPPLogLevel.debug.rawValue {
            let headersString = JSONUtil.stringify(request.allHTTPHeaderFields) ?? "nil"
            let paramsString = JSONUtil.stringify(params, prettyPrinted: true) ?? "nil"
            DebugLog.d(caller: HTTPClient.self, "Sending HTTP Request \(method): \(requestURL)\n  Headers: \(headersString)\n  Params: \(paramsString)\n")
        }
        
        return request
    }
    
    private func createRequest(method: HTTPMethod, path: String, headers: [String: String]?, params: [String: Any]?, data: Data? = nil) -> URLRequest? {
        
        guard let url = baseUrl?.appendingPathComponent(path) else {
                DebugLog.w(caller: self, "Failed to construct requestURL.")
            return nil
        }
        
        let request = createRequest(method: method, url: url, headers: headers, params: params, data: data)
        
        return request
    }
    
    private func resumeDataTask(with request: URLRequest, completion: @escaping DictCompletionHandler) {
        urlSession.dataTask(with: request) { (data, response, error) in
            var jsonMap: [String: Any]?
            let jsonObject = JSONUtil.getObjectFrom(data)
            
            if let jsonObject = jsonObject as? [String: Any] {
                jsonMap = jsonObject
            }
            
            completion(jsonMap, response, error)
        }.resume()
    }
    
    func sendRequest(method: HTTPMethod = .POST, url: URL, headers: [String: String]? = nil, params: [String: Any]? = nil, completion: @escaping DictCompletionHandler) {
        guard let request = createRequest(method: method, url: url, headers: headers, params: params) else {
            return
        }
        
        resumeDataTask(with: request, completion: completion)
    }
    
    func sendRequest(method: HTTPMethod = .POST, path: String, headers: [String: String]? = nil, params: [String: Any]? = nil, completion: @escaping DictCompletionHandler) {
        guard let request = createRequest(method: method, path: path, headers: headers, params: params) else {
            return
        }
        
        resumeDataTask(with: request, completion: completion)
    }
    
    func sendRequest(method: HTTPMethod = .POST, path: String, headers: [String: String]? = nil, params: [String: Any]? = nil, data: Data? = nil, completion: @escaping DataCompletionHandler) {
        guard let request = createRequest(method: method, path: path, headers: headers, params: params, data: data) else {
            return
        }
        
        urlSession.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }.resume()
    }
}

// MARK: - URL

extension HTTPClient {
    
    private func makeRequestURL(url: URL, params: [String: String]?) -> URL? {
        var urlComponents = URLComponents(string: url.absoluteString)
        if let params = params {
            var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
            for (name, value) in params {
                let queryItem = URLQueryItem(name: name, value: value)
                queryItems.append(queryItem)
            }
            urlComponents?.queryItems = queryItems
        }
        
        return urlComponents?.url
    }
}

// MARK: - Headers

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
