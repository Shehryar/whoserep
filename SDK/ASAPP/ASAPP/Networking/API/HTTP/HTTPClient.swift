//
//  HTTPClient.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum AuthError: Error {
    case invalid
    case retryAllowed
    case tokenExpired
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

protocol HTTPClientProtocol: class {
    typealias AuthenticationHandler = (Result<Session, AuthError>) -> Void
    typealias DictCompletionHandler = ([String: Any]?, URLResponse?, Error?) -> Void
    typealias DataCompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    
    var session: Session? { get set }
    var baseUrl: URL? { get }
    
    func config(_ config: ASAPPConfig)
    // swiftlint:disable:next function_parameter_count
    func sendRequest(method: HTTPMethod, path: String, headers: [String: String]?, params: [String: Any], data: Data?, completion: @escaping DataCompletionHandler)
    func sendRequest(method: HTTPMethod, path: String, headers: [String: String]?, params: [String: Any], completion: @escaping DictCompletionHandler)
    func sendRequest(method: HTTPMethod, url: URL, headers: [String: String]?, body: [String: Any], completion: @escaping DataCompletionHandler)
    func sendRequest(method: HTTPMethod, url: URL, headers: [String: String]?, params: [String: Any], completion: @escaping DictCompletionHandler)
    // swiftlint:disable:next function_parameter_count
    func sendRequest(method: HTTPMethod, url: URL, headers: [String: String]?, params: [String: Any], data: Data?, completion: @escaping DataCompletionHandler)
    func authenticate(as user: ASAPPUser, contextNeedsRefresh: Bool, shouldRetry: Bool, retries: Int, completion: @escaping AuthenticationHandler)
    func authenticate(as user: ASAPPUser, contextNeedsRefresh: Bool, completion: @escaping AuthenticationHandler)
}

extension HTTPClientProtocol {
    func sendRequest(
        method: HTTPMethod = .POST,
        path: String,
        headers: [String: String]? = nil,
        params: [String: Any] = [:],
        data: Data? = nil,
        completion: @escaping DataCompletionHandler) {
        return sendRequest(method: method, path: path, headers: headers, params: params, data: data, completion: completion)
    }
    
    func sendRequest(
        method: HTTPMethod = .POST,
        path: String,
        headers: [String: String]? = nil,
        params: [String: Any] = [:],
        completion: @escaping DictCompletionHandler) {
        return sendRequest(method: method, path: path, headers: headers, params: params, completion: completion)
    }
    
    func sendRequest(
        method: HTTPMethod = .POST,
        url: URL,
        headers: [String: String]? = nil,
        body: [String: Any] = [:],
        completion: @escaping DataCompletionHandler) {
        return sendRequest(method: method, url: url, headers: headers, body: body, completion: completion)
    }
    
    func sendRequest(
        method: HTTPMethod = .POST,
        url: URL,
        completion: @escaping DictCompletionHandler) {
        return sendRequest(method: method, url: url, headers: nil, params: [:], completion: completion)
    }
    
    func authenticate(as user: ASAPPUser, contextNeedsRefresh: Bool, completion: @escaping AuthenticationHandler) {
        return authenticate(as: user, contextNeedsRefresh: contextNeedsRefresh, shouldRetry: true, retries: 0, completion: completion)
    }
}

enum HTTPError: Error {
    case generalError(String)
    
    var localizedDescription: String {
        switch self {
        case .generalError(let message):
            return message
        }
    }
    
    var errorDescription: String? { return localizedDescription }
}

extension HTTPError: LocalizedError {}

class HTTPClient: NSObject, HTTPClientProtocol {
    static let shared = HTTPClient()
    
    var defaultHeaders: [String: String] = [:]
    
    var session: Session? {
        didSet {
            SavedSessionManager.shared.save(session: session)
            PushNotificationsManager.shared.session = session
        }
    }
    
    private let urlSession: URLSessionProtocol
    
    private(set) var baseUrl = URL(string: "")
    
    required init(urlSession: URLSessionProtocol? = nil) {
        if let urlSession = urlSession {
            self.urlSession = urlSession
        } else {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            let defaultUrlSession = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
            self.urlSession = defaultUrlSession
        }
    }
    
    static let defaultParams: [String: String] = [
        ASAPP.clientTypeKey: ASAPP.clientType,
        ASAPP.clientVersionKey: ASAPP.clientVersion,
        ASAPP.partnerAppVersionKey: ASAPP.partnerAppVersion
    ]
    
    func config(_ config: ASAPPConfig) {
        baseUrl = URL(string: "https://\(config.apiHostName)/api/http/v1/")
        defaultHeaders[ASAPP.clientTypeKey] = ASAPP.clientType
        defaultHeaders[ASAPP.clientVersionKey] = ASAPP.clientVersion
        defaultHeaders[ASAPP.clientSecretKey] = config.clientSecret
        defaultHeaders[ASAPP.partnerAppVersionKey] = ASAPP.partnerAppVersion
        defaultHeaders[ASAPP.appIdKey] = config.appId
        defaultHeaders[ASAPP.regionCodeKey] = config.regionCode
    }
    
    func getHeaders(for session: Session) -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(session.token)"
        ]
    }
    
    func getASAPPContext(for session: Session?) -> [String: Any] {
        return ["CompanyId": session?.companyId ?? 0]
    }
    
    // MARK: Sending Requests
    
    private func createRequest(method: HTTPMethod, url: URL, headers: [String: String]?, params: [String: Any]? = nil, body: [String: Any]? = nil, context: [String: Any]? = nil, data: Data? = nil) -> URLRequest? {
        var urlParams = HTTPClient.defaultParams
        if method == .GET {
            if let stringyParams = params as? [String: String] {
                urlParams.add(stringyParams)
            } else {
                DebugLog.w(caller: self, "GET params must be String values: \(String(describing: params))")
            }
        }
        
        guard let requestURL = makeRequestURL(url: url, params: urlParams) else {
            DebugLog.w(caller: self, "Failed to construct requestURL.")
            return nil
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        request.injectHeaders(defaultHeaders)
        if let session = session {
            request.injectHeaders(getHeaders(for: session))
        }
        request.injectHeaders(headers)
        
        let contextParams = context ?? getASAPPContext(for: session)
        
        if method != .GET {
            var dict: [String: Any]
            if let body = body {
                dict = body
            } else if let params = params {
                dict = [
                    "params": params,
                    "ctxParams": contextParams
                ] as [String: Any]
            } else {
                dict = [:]
            }
            if let data = data {
                dict["binaryBase64"] = data.base64EncodedString()
            }
            request.httpBody = JSONUtil.getDataFrom(dict)
        }
        
        if ASAPP.debugLogLevel.rawValue >= ASAPPLogLevel.debug.rawValue {
            let headersString = JSONUtil.stringify(request.allHTTPHeaderFields) ?? "nil"
            if let body = body {
                let bodyString = JSONUtil.stringify(body, prettyPrinted: true) ?? "nil"
                DebugLog.d(caller: HTTPClient.self, "Sending HTTP Request \(method): \(requestURL)\nHeaders: \(headersString)\nBody: \(bodyString)\n--------")
            } else {
                var paramsToPrint = params
                if ASAPP.debugLogLevel.rawValue < ASAPPLogLevel.info.rawValue {
                    let truncated = "[ truncated; set debugLogLevel to .info to see ]"
                    paramsToPrint?["Auth"] = truncated
                    paramsToPrint?["Context"] = truncated
                }
                let paramsString = JSONUtil.stringify(paramsToPrint, prettyPrinted: true) ?? "nil"
                let contextParamsString = method == .GET ? "N/A" : JSONUtil.stringify(contextParams, prettyPrinted: true) ?? "nil"
                DebugLog.d(caller: HTTPClient.self, "Sending HTTP Request \(method): \(requestURL)\nHeaders: \(headersString)\nparams: \(paramsString)\nctxParams: \(contextParamsString)\n--------")
            }
        }
        
        return request
    }
    
    private func createRequest(method: HTTPMethod, path: String, headers: [String: String]?, params: [String: Any], data: Data? = nil) -> URLRequest? {
        
        guard let url = baseUrl?.appendingPathComponent(path) else {
                DebugLog.w(caller: self, "Failed to construct requestURL.")
            return nil
        }
        
        return createRequest(method: method, url: url, headers: headers, params: params, data: data)
    }
    
    private func getError(from body: Data?, of response: URLResponse?) -> Error? {
        guard
            let body = body,
            let response = response,
            let statusCode = (response as? HTTPURLResponse)?.statusCode,
            statusCode >= 400
        else {
            return nil
        }
        
        let message: String
        if let responseString = String(data: body, encoding: .utf8) {
            message = ": \(responseString)"
        } else {
            message = ""
        }
        return HTTPError.generalError("Error \(statusCode)\(message)")
    }
    
    private func resumeDataTask(with request: URLRequest, completion: @escaping DictCompletionHandler) {
        urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            var error = error
            var jsonMap: [String: Any]?
            let jsonObject = JSONUtil.getObjectFrom(data)
            
            if let jsonObject = jsonObject as? [String: Any] {
                jsonMap = jsonObject
            }
            
            if error == nil,
               let bodyError = self?.getError(from: data, of: response) {
                error = bodyError
            }
            
            if response?.mimeType != "application/json",
               let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                DebugLog.d(caller: HTTPClient.self, "Received instead of JSON: \(responseString)")
            }
            
            if let error = error {
                DebugLog.d(caller: HTTPClient.self, error.localizedDescription)
            }
            
            completion(jsonMap, response as? HTTPURLResponse, error)
        }.resume()
    }
    
    func sendRequest(method: HTTPMethod = .POST, url: URL, headers: [String: String]? = nil, params: [String: Any] = [:], completion: @escaping DictCompletionHandler) {
        guard let request = createRequest(method: method, url: url, headers: headers, params: params) else {
            return
        }
        
        resumeDataTask(with: request, completion: completion)
    }
    
    func sendRequest(method: HTTPMethod = .POST, path: String, headers: [String: String]? = nil, params: [String: Any] = [:], completion: @escaping DictCompletionHandler) {
        guard let request = createRequest(method: method, path: path, headers: headers, params: params) else {
            return
        }
        
        resumeDataTask(with: request, completion: completion)
    }
    
    func sendRequest(method: HTTPMethod = .POST, url: URL, headers: [String: String]? = nil, body: [String: Any] = [:], data: Data? = nil, completion: @escaping DataCompletionHandler) {
        guard let request = createRequest(method: method, url: url, headers: headers, body: body, data: data) else {
            return
        }
        
        urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            completion(data, response as? HTTPURLResponse, error ?? self?.getError(from: data, of: response))
        }.resume()
    }
    
    func sendRequest(method: HTTPMethod = .POST, url: URL, headers: [String: String]? = nil, params: [String: Any] = [:], data: Data? = nil, completion: @escaping DataCompletionHandler) {
        guard let request = createRequest(method: method, url: url, headers: headers, params: params, data: data) else {
            return
        }
        
        urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            completion(data, response as? HTTPURLResponse, error ?? self?.getError(from: data, of: response))
        }.resume()
    }
    
    func sendRequest(method: HTTPMethod = .POST, path: String, headers: [String: String]? = nil, params: [String: Any] = [:], data: Data? = nil, completion: @escaping DataCompletionHandler) {
        guard let request = createRequest(method: method, path: path, headers: headers, params: params, data: data) else {
            return
        }
        
        urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            completion(data, response as? HTTPURLResponse, error ?? self?.getError(from: data, of: response))
        }.resume()
    }
}

// MARK: - Authentication

extension HTTPClient {
    // MARK: Getting a session token
    
    /**
     Authenticate by trading an access token for a session token.
     
     - parameter retry: Times to recursively retry with a delay that increments by 3 seconds
     */
    func authenticate(as user: ASAPPUser, contextNeedsRefresh: Bool, shouldRetry: Bool = true, retries: Int = 0, completion: @escaping AuthenticationHandler) {
        let maxRetries = 5
        
        func getDelay(forRetry retry: Int) -> DispatchTimeInterval {
            return .seconds(retry * 3)
        }
        
        guard let url = baseUrl?.replacingPath(with: "/api/v2/customer/auth") else {
            return
        }
        
        user.getContext(needsRefresh: contextNeedsRefresh) { [weak self] (context, accessToken) in
            var body: [String: Any] = [:]
            
            if let accessToken = accessToken {
                body["auth"] = accessToken
            }
            
            if let context = context {
                body["context"] = context
            }
            
            if !user.isAnonymous {
                body["customer_identifier"] = user.userIdentifier
                body["identifier_type"] = ASAPP.config.identifierType
            }
            
            self?.sendRequest(method: .POST, url: url, body: body) { [weak self] (data, _, error) in
                if let error = error {
                    DebugLog.e(caller: HTTPClient.self, "\(url) responded with error:", error.localizedDescription)
                }
                
                let authError: AuthError
                if error == nil,
                    let data = data,
                   let string = String(data: data, encoding: .utf8),
                   let stringData = string.data(using: .utf8),
                   var session = try? JSONDecoder().decode(Session.self, from: stringData) {
                    session.fullInfo = data
                    self?.session = session
                    return completion(.success(session))
                } else if let data = data,
                    let dict = JSONUtil.getObjectFrom(data) as? [String: Any],
                    let errorString = dict["error"] as? String {
                    if errorString == "token_expired" {
                        authError = .tokenExpired
                    } else if errorString == "invalid_auth" {
                        authError = .invalid
                    } else {
                        authError = .retryAllowed
                    }
                } else {
                    authError = .retryAllowed
                }
                
                self?.session = nil
                
                if authError == .invalid {
                    completion(.failure(.invalid))
                    return
                }
                
                if shouldRetry,
                   retries < maxRetries {
                    if retries == 1 {
                        if authError == .tokenExpired {
                            completion(.failure(.tokenExpired))
                        } else {
                            completion(.failure(.retryAllowed))
                        }
                    }
                    
                    let nextRetry = retries + 1
                    Dispatcher.delay(getDelay(forRetry: nextRetry), qos: .utility) { [weak self] in
                        DebugLog.d(caller: HTTPClient.self, Date().debugDescription, "retrying authentication (retry #\(nextRetry))")
                        self?.authenticate(as: user, contextNeedsRefresh: authError == .tokenExpired, shouldRetry: true, retries: nextRetry, completion: completion)
                    }
                    return
                }
                
                completion(.failure(authError == .tokenExpired ? .tokenExpired : .retryAllowed))
            }
        }
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
