//
//  RMSOAuthError.swift
//  RMSOAuth
//
//  Created by Developer on 29/10/21.
//

import Foundation


// MARK: - RMSOAuth errors
public enum RMSOAuthError: Error {

    /// Configuration problem with oauth provider.
    case configurationError(message: String)
    /// State missing from request (you can set allowMissingStateCheck = true to ignore)
    case missingState
    /// Returned state value is wrong
    case stateNotEqual(state: String, responseState: String)
    /// Error from server
    case serverError(message: String)
    /// Failed to create URL \(urlString) not convertible to URL, please encode
    case encodingError(urlString: String)
    /// Failed to create request with \(urlString)
    case requestCreation(message: String)
    /// Authentification failed. No token
    case missingToken
    /// Please retain RMSOAuth object or handle
    case retain
    /// Request cancelled
    case cancelled

    /// Generic request error
    case requestError(error: Error, request: URLRequest, statusCode: Int, statusMessage: String)
    /// The provided token is expired, retrieve new token by using the refresh token
    case tokenExpired(error: Error?)
    /// If the user has not either allowed or denied the request yet, the authorization server will return the authorization_pending error.
    case authorizationPending(error: Error, request: URLRequest)
    /// If the device is polling too frequently, the authorization server will return the slow_down error.
    case slowDown(error: Error, request: URLRequest)
    /// If the user denies the request.
    case accessDenied(error: Error, request: URLRequest)

    public static let Domain = "RMSOAuthError"
    public static let ResponseDataKey = "RMSOAuthError.response.data"
    public static let ResponseKey = "RMSOAuthError.response"

    fileprivate enum Code: Int {
        case configurationError = -1
        case tokenExpired = -2
        case missingState = -3
        case stateNotEqual = -4
        case serverError = -5
        case encodingError = -6
        case authorizationPending = -7
        case requestCreation = -8
        case missingToken = -9
        case retain = -10
        case requestError = -11
        case cancelled = -12
        case slowDown = -13
        case accessDenied = -14
    }

    fileprivate var code: Code {
        switch self {
        case .configurationError: return Code.configurationError
        case .tokenExpired: return Code.tokenExpired
        case .missingState: return Code.missingState
        case .stateNotEqual: return Code.stateNotEqual
        case .serverError: return Code.serverError
        case .encodingError: return Code.encodingError
        case .cancelled : return Code.cancelled
        case .requestCreation: return Code.requestCreation
        case .missingToken: return Code.missingToken
        case .retain: return Code.retain
        case .requestError: return Code.requestError
        case .authorizationPending: return Code.authorizationPending
        case .slowDown: return Code.slowDown
        case .accessDenied: return Code.accessDenied
        }
    }

    public var underlyingError: Error? {
        switch self {
        case .tokenExpired(let e): return e
        case .requestError(let e, _, _,_): return e
        case .authorizationPending(let e, _): return e
        case .slowDown(let e, _): return e
        case .accessDenied(let e, _): return e
        default: return nil
        }
    }
    

    public var underlyingMessage: String? {
        switch self {
        case .serverError(let m): return m
        case .configurationError(let m): return m
        case .requestCreation(let m): return m
        default: return nil
        }
    }

}

extension RMSOAuthError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .configurationError(let m): return "configurationError[\(m)]"
        case .tokenExpired(let e): return "tokenExpired[\(String(describing: e))]"
        case .missingState: return "missingState"
        case .stateNotEqual(let s, let e): return "stateNotEqual[\(s)<>\(e)]"
        case .serverError(let m): return "serverError[\(m)]"
        case .encodingError(let urlString): return "encodingError[\(urlString)]"
        case .requestCreation(let m): return "requestCreation[\(m)]"
        case .missingToken: return "missingToken"
        case .retain: return "retain"
        case .requestError(let e, _, _,_): return "requestError[\(e)]"
        case .slowDown : return "slowDown"
        case .accessDenied : return "accessDenied"
        case .authorizationPending: return "authorizationPending"
        case .cancelled : return "cancelled"
        }
    }
}

extension RMSOAuth {
    static func retainError(_ completionHandler: RMSOAuthHTTPRequest.CompletionHandler?) {
        #if !OAUTH_NO_RETAIN_ERROR
            completionHandler?(.failure(RMSOAuthError.retain))
        #endif
    }
    static func retainError(_ completionHandler: TokenCompletionHandler?) {
        #if !OAUTH_NO_RETAIN_ERROR
        completionHandler?(.failure(RMSOAuthError.retain))
        #endif
    }
}

// MARK: NSError
extension RMSOAuthError: CustomNSError {

    public static var errorDomain: String { return RMSOAuthError.Domain }

    public var errorCode: Int { return self.code.rawValue }

    /// The user-info dictionary.
    public var errorUserInfo: [String: Any] {
        switch self {
        case .configurationError(let m): return ["message": m]
        case .serverError(let m): return ["message": m]
        case .requestCreation(let m): return ["message": m]

        case .tokenExpired(let e): return ["error": e as Any]
        case .requestError(let e, let request, let code, let statusMessage): return ["error": e, "request": request, "statusCode": code, "statusMessage": statusMessage]
        case .authorizationPending(let e, let request): return ["error": e, "request": request]
        case .slowDown(let e, let request): return ["error": e, "request": request]
        case .accessDenied(let e, let request): return ["error": e, "request": request]

        case .encodingError(let urlString): return ["url": urlString]

        case .stateNotEqual(let s, let e): return ["state": s, "expected": e]
        default: return [:]
        }
    }

    public var _code: Int {
        return self.code.rawValue
    }
    public var _domain: String {
        return RMSOAuthError.Domain
    }
}
