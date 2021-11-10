//
//  RMSOAuth2.swift
//  MainPOS
//
//  Created by Developer on 29/10/21.
//

import Foundation

public class RMSOAuth2: RMSOAuth {

    /// If your oauth provider need to use basic authentification
    /// set value to true (default: false)
    open var accessTokenBasicAuthentification = false

    /// Set to true to deactivate state check. Be careful of CSRF
    open var allowMissingStateCheck: Bool = false

    /// Encode callback url, some services require it to be encoded.
    open var encodeCallbackURL: Bool = false

    /// Encode callback url inside the query, this is second encoding phase when the entire query string gets assembled. In rare
    /// cases, like with Imgur, the url needs to be encoded only once and this value needs to be set to `false`.
    open var encodeCallbackURLQuery: Bool = true

    var clientID: String
    var clientSecret: String
    var authorizeUrl: String
    var accessTokenUrl: String?
    var responseType: String
    var contentType: String?
    // RFC7636 PKCE
    var codeVerifier: String?

    // MARK: init
    public init(clientID: String, clientSecret: String, authorizeUrl: URLConvertible, accessTokenUrl: URLConvertible? = nil, responseType: String, contentType: String? = nil) {
        self.accessTokenUrl = accessTokenUrl?.string
        self.contentType = contentType
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeUrl = authorizeUrl.string
        self.responseType = responseType
        super.init(clientID: clientID, clientSecret: clientSecret)
        self.client.credential.version = .oauth2
    }

    public convenience init?(parameters: ConfigParameters) {
        guard let clientID = parameters["clientID"], let clientSecret = parameters["clientSecret"],
            let responseType = parameters["responseType"], let authorizeUrl = parameters["authorizeUrl"] else {
                return nil
        }
        if let accessTokenUrl = parameters["accessTokenUrl"] {
            self.init(clientID: clientID, clientSecret: clientSecret,
                      authorizeUrl: authorizeUrl, accessTokenUrl: accessTokenUrl, responseType: responseType)
        } else {
            self.init(clientID: clientID, clientSecret: clientSecret,
                      authorizeUrl: authorizeUrl, responseType: responseType)
        }
    }

    open var parameters: ConfigParameters {
        return [
            "clientID": clientID,
            "clientSecret": clientSecret,
            "authorizeUrl": authorizeUrl,
            "accessTokenUrl": accessTokenUrl ?? "",
            "responseType": responseType
        ]
    }

    // MARK: functions

    /// Handling SFAuthenticationSession/ASWebAuthenticationSession canceledLogin errors
    fileprivate func isCancelledError(_ responseParameters: [String: String]) -> Bool {
        guard let domain = responseParameters["error_domain"],
              let codeString = responseParameters["error_code"],
              let code = Int(codeString) else {
            return false
        }

        #if targetEnvironment(macCatalyst) || os(iOS)
        if #available(iOS 13.0, macCatalyst 13.0, *),
           ASWebAuthenticationURLHandler.isCancelledError(domain: domain, code: code) {
            return true
        }
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 11, *),
           SFAuthenticationURLHandler.isCancelledError(domain: domain, code: code) {
            return true
        }
        #endif
        #endif
        return false
    }

    @discardableResult
    open func authorize(withCallbackURL callbackURL: URLConvertible?, scope: String, state: String, parameters: Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: @escaping TokenCompletionHandler) -> RMSOAuthRequestHandle? {

        //RMSOAuth.log?.trace("Start authorization ...")
        if let url = callbackURL, url.url == nil {
            completion(.failure(.encodingError(urlString: url.string)))
            return nil
        }
        self.observeCallback { [weak self] url in

            //RMSOAuth.log?.trace("Open application resource url: \(url.absoluteString)")
            guard let this = self else {
                RMSOAuth.retainError(completion)
                return
            }
            var responseParameters = [String: String]()
            if let query = url.query {
                responseParameters += query.parametersFromQueryString
            }
            if let fragment = url.fragment, !fragment.isEmpty {
                responseParameters += fragment.parametersFromQueryString
            }
            //RMSOAuth.log?.trace("Parsed url parameters: \(responseParameters)")

            if let accessToken = responseParameters["access_token"] {
                this.client.credential.oauthToken = accessToken.safeStringByRemovingPercentEncoding
                if let expiresIn: String = responseParameters["expires_in"], let offset = Double(expiresIn) {
                    this.client.credential.oauthTokenExpiresAt = Date(timeInterval: offset, since: Date())
                }
                completion(.success((this.client.credential, nil, responseParameters)))
            } else if let code = responseParameters["code"] {
                if !this.allowMissingStateCheck {
                    guard let responseState = responseParameters["state"] else {
                        //RMSOAuth.log?.error("Resource url: Missing 'state' parameter")
                        completion(.failure(.missingState))
                        return
                    }
                    if responseState != state {
                        //RMSOAuth.log?.error("Resource url: Unmatched 'state' parameter")
                        completion(.failure(.stateNotEqual(state: state, responseState: responseState)))
                        return
                    }
                }
                let callbackURLEncoded: URL?
                if let callbackURL = callbackURL {
                    callbackURLEncoded = callbackURL.encodedURL // XXX do not known why to re-encode, maybe if string only?
                } else {
                    callbackURLEncoded = nil
                }
                if let handle = this.postOAuthAccessTokenWithRequestToken(
                    byCode: code.safeStringByRemovingPercentEncoding,
                    callbackURL: callbackURLEncoded, headers: headers, completionHandler: completion) {
                    this.putHandle(handle, withKey: UUID().uuidString)
                }
            } else if let error = responseParameters["error"] {
                if this.isCancelledError(responseParameters) {
                    completion(.failure(.cancelled))
                } else {
                    let description = responseParameters["error_description"] ?? ""
                    let message = NSLocalizedString(error, comment: description)
                    //RMSOAuth.log?.error("Authorization failed with: \(description)")
                    completion(.failure(.serverError(message: message)))
                }
            } else {
                let message = "No access_token, no code and no error provided by server"
                //RMSOAuth.log?.error("Authorization failed with: \(message)")
                completion(.failure(.serverError(message: message)))
            }
        }

        var queryErrorString = ""
        let encodeError: (String, String) -> Void = { name, value in
            if let newQuery = queryErrorString.urlQueryByAppending(parameter: name, value: value, encode: false) {
                queryErrorString = newQuery
            }
        }

        var queryString: String? = ""
        queryString = queryString?.urlQueryByAppending(parameter: "client_id", value: self.clientID, encodeError)
        if let callbackURL = callbackURL {
            let value = self.encodeCallbackURL ? callbackURL.string.urlEncoded : callbackURL.string
            queryString = queryString?.urlQueryByAppending(parameter: "redirect_uri", value: value, encode: self.encodeCallbackURLQuery, encodeError)
        }
        queryString = queryString?.urlQueryByAppending(parameter: "response_type", value: self.responseType, encodeError)
        queryString = queryString?.urlQueryByAppending(parameter: "scope", value: scope, encodeError)
        queryString = queryString?.urlQueryByAppending(parameter: "state", value: state, encodeError)

        for (name, value) in parameters {
            queryString = queryString?.urlQueryByAppending(parameter: name, value: "\(value)", encodeError)
        }

        if let queryString = queryString {
            let urlString = self.authorizeUrl.urlByAppending(query: queryString)
            if let url: URL = URL(string: urlString) {
                self.authorizeURLHandler.handle(url)
                return self
            } else {
                //RMSOAuth.log?.error("Resource url: Invalid query string: \(urlString)")
                completion(.failure(.encodingError(urlString: urlString)))
            }
        } else {
            let urlString = self.authorizeUrl.urlByAppending(query: queryErrorString)
            //RMSOAuth.log?.error("Resource url: Invalid query string: \(urlString)")
            completion(.failure(.encodingError(urlString: urlString)))
        }
        self.cancel() // ie. remove the observer.
        return nil
    }

    open func postOAuthAccessTokenWithRequestToken(byCode code: String, callbackURL: URL?, headers: RMSOAuth.Headers? = nil, completionHandler completion: @escaping TokenCompletionHandler) -> RMSOAuthRequestHandle? {

        var parameters = RMSOAuth.Parameters()
        parameters["client_id"] = self.clientID
        parameters["code"] = code
        parameters["grant_type"] = "authorization_code"

        // PKCE - extra parameter
        if let codeVerifier = self.codeVerifier {
            parameters["code_verifier"] = codeVerifier
            // Don't send client secret when using PKCE, some services complain
        } else {
            // client secrets should only be used for web style apps where they can't be decompiled (use pkce instead), so if it's empty, don't post it as some servers will reject it
            // https://www.oauth.com/oauth2-servers/client-registration/client-id-secret/
            if !self.clientSecret.isEmpty {
                parameters["client_secret"] = self.clientSecret
            }
        }

        if let callbackURL = callbackURL {
            parameters["redirect_uri"] = callbackURL.absoluteString.safeStringByRemovingPercentEncoding
        }

        //RMSOAuth.log?.trace("Add security parameters: \(parameters)")
        return requestOAuthAccessToken(withParameters: parameters, headers: headers, completionHandler: completion)
    }

    @discardableResult
    open func renewAccessToken(withRefreshToken refreshToken: String, parameters: RMSOAuth.Parameters? = nil, headers: RMSOAuth.Headers? = nil, completionHandler completion: @escaping TokenCompletionHandler) -> RMSOAuthRequestHandle? {
        return self.client.renewAccessToken(accessTokenUrl: self.accessTokenUrl, withRefreshToken: refreshToken, parameters: parameters ?? RMSOAuth.Parameters(), headers: headers, completionHandler: completion)
    }

    fileprivate func requestOAuthAccessToken(withParameters parameters: RMSOAuth.Parameters, headers: RMSOAuth.Headers? = nil, completionHandler completion: @escaping TokenCompletionHandler) -> RMSOAuthRequestHandle? {
        return self.client.requestOAuthAccessToken(accessTokenUrl: self.accessTokenUrl, withParameters: parameters, headers: headers, contentType: self.contentType, accessTokenBasicAuthentification: self.accessTokenBasicAuthentification, completionHandler: completion)
    }

    /**
     Convenience method to start a request that must be authorized with the previously retrieved access token.
     Since OAuth 2 requires support for the access token refresh mechanism, this method will take care to automatically
     refresh the token if needed such that the developer only has to be concerned about the outcome of the request.
     
     - parameter url:            The url for the request.
     - parameter method:         The HTTP method to use.
     - parameter parameters:     The request's parameters.
     - parameter headers:        The request's headers.
     - parameter renewHeaders:   The request's headers if renewing. If nil, the `headers`` are used when renewing.
     - parameter body:           The request's HTTP body.
     - parameter onTokenRenewal: Optional callback triggered in case the access token renewal was required in order to properly authorize the request.
     - parameter success:        The success block. Takes the successfull response and data as parameter.
     - parameter failure:        The failure block. Takes the error as parameter.
     */
    @discardableResult
    open func startAuthorizedRequest(_ url: URLConvertible, method: RMSOAuthHTTPRequest.Method, parameters: RMSOAuth.Parameters, headers: RMSOAuth.Headers? = nil, renewHeaders: RMSOAuth.Headers? = nil, body: Data? = nil, onTokenRenewal: TokenRenewedHandler? = nil, completionHandler completion: @escaping RMSOAuthHTTPRequest.CompletionHandler) -> RMSOAuthRequestHandle? {

        //RMSOAuth.log?.trace("Start authorized request, url: \(url.url?.absoluteString ?? "unknown") ...")
        let completionHandler: RMSOAuthHTTPRequest.CompletionHandler = { result in
            switch result {
            case .success:
                completion(result)
            case .failure(let error): // map/recovery error
                switch error {
                case RMSOAuthError.tokenExpired:
                    let renewCompletionHandler: TokenCompletionHandler = { result in
                        switch result {
                        case .success(let (credential, _, _)):
                            // Ommit response parameters so they don't override the original ones
                            // We have successfully renewed the access token.

                            // If provided, fire the onRenewal closure
                            if let renewalCallBack = onTokenRenewal {
                                renewalCallBack(.success(credential))
                            }

                            // Reauthorize the request again, this time with a brand new access token ready to be used.
                            _ = self.startAuthorizedRequest(url, method: method, parameters: parameters, headers: headers, body: body, onTokenRenewal: onTokenRenewal, completionHandler: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }

                    _ = self.renewAccessToken(withRefreshToken: self.client.credential.oauthRefreshToken, headers: renewHeaders ?? headers, completionHandler: renewCompletionHandler)
                default:
                    completion(.failure(error))
                }
            }
        }

        // build request
        return self.client.request(url, method: method, parameters: parameters, headers: headers, body: body, completionHandler: completionHandler)
    }

    // OAuth 2.0 Specification: https://tools.ietf.org/html/draft-ietf-oauth-v2-13#section-4.3
    @discardableResult
    open func authorize(username: String, password: String, scope: String?, headers: RMSOAuth.Headers? = nil, completionHandler completion: @escaping TokenCompletionHandler) -> RMSOAuthRequestHandle? {

        var parameters = RMSOAuth.Parameters()
        parameters["client_id"] = self.clientID
        if !self.clientSecret.isEmpty {
            parameters["client_secret"] = self.clientSecret
        }
        parameters["username"] = username
        parameters["password"] = password
        parameters["grant_type"] = "password"

        if let scope = scope {
            parameters["scope"] = scope
        }

        return requestOAuthAccessToken(
            withParameters: parameters,
            headers: headers,
            completionHandler: completion
        )
    }

    @discardableResult
    open func authorize(deviceToken deviceCode: String, grantType: String = "http://oauth.net/grant_type/device/1.0", completionHandler completion: @escaping TokenCompletionHandler) -> RMSOAuthRequestHandle? {
        var parameters = RMSOAuth.Parameters()
        parameters["client_id"] = self.clientID
        parameters["client_secret"] = self.clientSecret
        parameters["code"] = deviceCode
        parameters["grant_type"] = grantType

        return requestOAuthAccessToken(
            withParameters: parameters,
            completionHandler: completion
        )
    }

    /// use RFC7636 PKCE credentials - convenience method
    @discardableResult
    open func authorize(withCallbackURL url: URLConvertible, scope: String, state: String, codeChallenge: String, codeChallengeMethod: String = "S256", codeVerifier: String, parameters: Parameters = [:], headers: RMSOAuth.Headers? = nil, completionHandler completion: @escaping TokenCompletionHandler) -> RMSOAuthRequestHandle? {
        guard let callbackURL = url.url else {
            completion(.failure(.encodingError(urlString: url.string)))
            return nil
        }

        // remember code_verifier
        self.codeVerifier = codeVerifier
        // PKCE - extra parameter
        var pkceParameters = Parameters()
        pkceParameters["code_challenge"] = codeChallenge
        pkceParameters["code_challenge_method"] = codeChallengeMethod

        return authorize(withCallbackURL: callbackURL, scope: scope, state: state, parameters: parameters + pkceParameters, headers: headers, completionHandler: completion)
    }
}
