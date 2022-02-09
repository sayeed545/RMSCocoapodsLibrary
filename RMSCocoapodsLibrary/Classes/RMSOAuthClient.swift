//
//  RMSOAuthClient.swift
//  RMSOAuth
//
//  Created by Developer on 29/10/21.
//

import Foundation


public var RMSOAuthDataEncoding: String.Encoding = .utf8

@objc public protocol RMSOAuthRequestHandle {
    func cancel()
}

open class RMSOAuthClient: NSObject {

    fileprivate(set) open var credential: RMSOAuthCredential
    open var paramsLocation: RMSOAuthHTTPRequest.ParamsLocation = .authorizationHeader
    /// Contains default URL session configuration
    open var sessionFactory = URLSessionFactory()
    open var activeTerminalURL: String = ""

    static let separator: String = "\r\n"
    static var separatorData: Data = {
        return RMSOAuthClient.separator.data(using: RMSOAuthDataEncoding)!
    }()

    // MARK: init
    public init(credential: RMSOAuthCredential) {
        self.credential = credential
    }

    public convenience init(clientID: String, clientSecret: String, version: RMSOAuthCredential.Version = .oauth1) {
        let credential = RMSOAuthCredential(clientID: clientID, clientSecret: clientSecret)
        credential.version = version
        self.init(credential: credential)
    }

    public convenience init(clientID: String, clientSecret: String, oauthToken: String, oauthTokenSecret: String, version: RMSOAuthCredential.Version) {
        self.init(clientID: clientID, clientSecret: clientSecret, version: version)
        self.credential.oauthToken = oauthToken
        self.credential.oauthTokenSecret = oauthTokenSecret
        
    }

    // MARK: client methods
    @discardableResult
    open func get(_ url: URLConvertible, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request(url, method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    
    @discardableResult
    open func getTerminalList( parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.credential.baseURL)/terminal", method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    
    @discardableResult
    open func getTransactionList( parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.activeTerminalURL)/transaction", method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    @discardableResult
    open func getTransactionListByType(transactionType: String, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.activeTerminalURL)/transaction?transactionType=\(transactionType)", method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    @discardableResult
    open func getTransactionListByStage(transactionStage: String, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.activeTerminalURL)/transaction?transactionStage=\(transactionStage)", method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    @discardableResult
    open func getTransactionListByStatus(transactionStatus: String, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.activeTerminalURL)/transaction?transactionStatus=\(transactionStatus)", method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    @discardableResult
    open func getTransactionListByAll(transactionType: String, transactionStage: String, transactionStatus: String, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.activeTerminalURL)/transaction?transactionType=\(transactionType)&transactionStage=\(transactionStage)&transactionStatus=\(transactionStatus)", method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    @discardableResult
    open func checkTransactionStatus(transactionId: String, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.activeTerminalURL)/transaction/\(transactionId)", method: .GET, parameters: parameters, headers: headers, completionHandler: completion)
    }
    open func setActiveTerminal(terminal: NSDictionary) {
        self.activeTerminalURL = "\(((terminal.value(forKey: "_links") as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href") as! NSString)";
    }
    open func setActiveTerminalById(terminalId: NSString) {
        self.activeTerminalURL = "\(self.credential.baseURL)/terminal\(terminalId)";
    }

    @discardableResult
    open func post(_ url: URLConvertible, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, body: Data? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request(url, method: .POST, parameters: parameters, headers: headers, body: body, completionHandler: completion)
    }
    @discardableResult
    open func requestReportByType(type: String, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, body: Data? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request("\(self.activeTerminalURL)/report/\(type)", method: .POST, parameters: [:], headers: headers, body: nil, completionHandler: completion)
    }
    @discardableResult
    open func CreateTransaction(amount: Int, currency: String, transactionType : String, amountCashBack : Int? = 0, completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        var headers = RMSOAuth.Headers();
        headers["Accept"] = "*/*"
        headers["Content-Type"] = "application/json"
        headers["Connection"] = "keep-alive"
        
        var parameters = RMSOAuth.Parameters();
        parameters["amount"] = amount
        parameters["currency"] = currency
        parameters["transactionType"] = transactionType
        parameters["amountCashback"] = amountCashBack
        
        return self.request("\(self.activeTerminalURL)/transaction", method: .POST, parameters:parameters, headers:headers, body: nil, completionHandler: completion)
    }

    @discardableResult
    open func put(_ url: URLConvertible, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, body: Data? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request(url, method: .PUT, parameters: parameters, headers: headers, body: body, completionHandler: completion)
    }

    @discardableResult
    open func delete(_ url: URLConvertible, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request(url, method: .DELETE, parameters: parameters, headers: headers, completionHandler: completion)
    }
    @discardableResult
    open func cancelTransaction(transactionId: String,  parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
    
        return self.request("\(self.activeTerminalURL)/transaction/\(transactionId)", method: .DELETE, parameters: parameters, headers: nil, completionHandler: completion)
    }

    @discardableResult
    open func patch(_ url: URLConvertible, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {
        return self.request(url, method: .PATCH, parameters: parameters, headers: headers, completionHandler: completion)
    }

    @discardableResult
    open func request(_ url: URLConvertible, method: RMSOAuthHTTPRequest.Method, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, body: Data? = nil, checkTokenExpiration: Bool = true, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) -> RMSOAuthRequestHandle? {

        if checkTokenExpiration && self.credential.isTokenExpired() {
            completion?(.failure(.tokenExpired(error: nil)))
            return nil
        }

        guard url.url != nil else {
            completion?(.failure(.encodingError(urlString: url.string)))
            return nil
        }

        if let request = makeRequest(url, method: method, parameters: parameters, headers: headers, body: body) {
            request.start(completionHandler: completion)
            return request
        }
        return nil
    }

    open func makeRequest(_ request: URLRequest) -> RMSOAuthHTTPRequest {
        let request = RMSOAuthHTTPRequest(request: request, paramsLocation: self.paramsLocation, sessionFactory: self.sessionFactory)
        request.config.updateRequest(credential: self.credential)
        return request
    }

    open func makeRequest(_ url: URLConvertible, method: RMSOAuthHTTPRequest.Method, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, body: Data? = nil) -> RMSOAuthHTTPRequest? {
        guard let url = url.url else {
            return nil // XXX failure not thrown here
        }

        let request = RMSOAuthHTTPRequest(url: url, method: method, parameters: parameters, paramsLocation: self.paramsLocation, httpBody: body, headers: headers ?? [:], sessionFactory: self.sessionFactory)
        request.config.updateRequest(credential: self.credential)
        return request
    }


    // MARK: Refresh Token
    @discardableResult
    open func renewAccessToken(accessTokenUrl: URLConvertible?, withRefreshToken refreshToken: String, parameters: RMSOAuth.Parameters? = nil, headers: RMSOAuth.Headers? = nil, contentType: String? = nil, accessTokenBasicAuthentification: Bool = false, completionHandler completion: @escaping RMSOAuth.TokenCompletionHandler) -> RMSOAuthRequestHandle? {
        // The current access token isn't needed anymore.
        self.credential.oauthToken = ""

        var parameters = parameters ?? RMSOAuth.Parameters()
        parameters["client_id"] = self.credential.clientID
        parameters["refresh_token"] = refreshToken
        parameters["grant_type"] = "refresh_token"

        // Omit the consumer secret if it's empty; this makes token renewal consistent with PKCE authorization.
        if !self.credential.clientSecret.isEmpty {
            parameters["client_secret"] = self.credential.clientSecret
        }

        //RMSOAuth.log?.trace("Renew access token, parameters: \(parameters)")
        return requestOAuthAccessToken(accessTokenUrl: accessTokenUrl, withParameters: parameters, headers: headers, contentType: contentType, accessTokenBasicAuthentification: accessTokenBasicAuthentification, completionHandler: completion)
    }

    func requestOAuthAccessToken(accessTokenUrl: URLConvertible?, withParameters parameters: RMSOAuth.Parameters, headers: RMSOAuth.Headers? = nil, contentType: String? = nil, accessTokenBasicAuthentification: Bool = false, completionHandler completion: @escaping RMSOAuth.TokenCompletionHandler) -> RMSOAuthRequestHandle? {
        //RMSOAuth.log?.trace("Request Oauth access token ...")
        let completionHandler: RMSOAuthHTTPRequest.CompletionHandler = { [weak self] result in
            guard let this = self else {
                RMSOAuth.retainError(completion)
                return
            }
            switch result {
            case .success(let response):
                //RMSOAuth.log?.trace("Oauth access token response ...")

                let responseJSON: Any? = try? response.jsonObject(options: .mutableContainers)

                let responseParameters: RMSOAuth.Parameters

                if let jsonDico = responseJSON as? [String: Any] {
                    responseParameters = jsonDico
                } else {
                    responseParameters = response.string?.parametersFromQueryString ?? [:]
                }

                guard let accessToken = responseParameters["access_token"] as? String else {
                    let message = NSLocalizedString("Could not get Access Token", comment: "Due to an error in the OAuth2 process, we couldn't get a valid token.")
                    //RMSOAuth.log?.error("Could not get access token")
                    completion(.failure(.serverError(message: message)))
                    return
                }

                if let refreshToken = responseParameters["refresh_token"] as? String {
                    this.credential.oauthRefreshToken = refreshToken.safeStringByRemovingPercentEncoding
                }

                if let expiresIn = responseParameters["expires_in"] as? String, let offset = Double(expiresIn) {
                    this.credential.oauthTokenExpiresAt = Date(timeInterval: offset, since: Date())
                } else if let expiresIn = responseParameters["expires_in"] as? Double {
                    this.credential.oauthTokenExpiresAt = Date(timeInterval: expiresIn, since: Date())
                }

                this.credential.oauthToken = accessToken.safeStringByRemovingPercentEncoding
                completion(.success((this.credential, response, responseParameters)))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        guard let accessTokenUrl = accessTokenUrl else {
            let message = NSLocalizedString("access token url not defined", comment: "access token url not defined with code type auth")
            //RMSOAuth.log?.error("Access token url not defined")
            completion(.failure(.configurationError(message: message)))
            return nil
        }

            // special headers
            var finalHeaders: RMSOAuth.Headers? = headers
            if accessTokenBasicAuthentification {
                let authentification = "\(self.credential.clientID):\(self.credential.clientSecret)".data(using: String.Encoding.utf8)
                if let base64Encoded = authentification?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
                    finalHeaders += ["Authorization": "Basic \(base64Encoded)"] as RMSOAuth.Headers
                }
            }
            // Request new access token by disabling check on current token expiration. This is safe because the implementation wants the user to retrieve a new token.
            return self.request(accessTokenUrl, method: .POST, parameters: parameters, headers: finalHeaders, checkTokenExpiration: false, completionHandler: completionHandler)
    }

    open func requestWithAutomaticAccessTokenRenewal(url: URL, method: RMSOAuthHTTPRequest.Method, parameters: RMSOAuth.Parameters = [:], headers: RMSOAuth.Headers? = nil, contentType: String? = nil, accessTokenBasicAuthentification: Bool = false, accessTokenUrl: URLConvertible, onTokenRenewal: RMSOAuth.TokenRenewedHandler?, completionHandler completion: RMSOAuthHTTPRequest.CompletionHandler?) {
        self.request(url, method: method, parameters: parameters, headers: headers) { [weak self] result in
            guard let this = self else {
                RMSOAuth.retainError(completion)
                return
            }

            switch result {
            case .success(let response):
                if let completion = completion {
                    completion(.success(response))
                }

            case .failure(let error):
                switch error {
                case RMSOAuthError.tokenExpired:
                    if let onTokenRenewal = onTokenRenewal {
                        let renewCompletionHandler: RMSOAuth.TokenCompletionHandler = { result in
                            switch result {
                            case .success(let (credential, _, _)):
                                onTokenRenewal(.success(credential))
                                this.requestWithAutomaticAccessTokenRenewal(url: url, method: method, parameters: parameters, headers: headers, contentType: contentType, accessTokenBasicAuthentification: accessTokenBasicAuthentification, accessTokenUrl: accessTokenUrl, onTokenRenewal: nil, completionHandler: completion)
                            case .failure(let error):
                                if let completion = completion {
                                    completion(.failure(.tokenExpired(error: error)))
                                }
                            }
                        }

                        _ = this.renewAccessToken(accessTokenUrl: accessTokenUrl, withRefreshToken: this.credential.oauthRefreshToken, headers: headers, contentType: contentType, accessTokenBasicAuthentification: accessTokenBasicAuthentification, completionHandler: renewCompletionHandler)
                    } else {
                        if let completion = completion {
                            completion(.failure(.tokenExpired(error: nil)))
                        }
                    }

                default:
                    if let completion = completion {
                        completion(.failure(.tokenExpired(error: nil)))
                    }
                }
            }
        }
    }
}
