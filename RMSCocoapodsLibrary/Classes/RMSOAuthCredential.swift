//
//  RMSOAuthCredential.swift
//  RMSOAuth
//
//  Created by Developer on 29/10/21.
//

import Foundation


/// Allow to customize computed headers
public protocol RMSOAuthCredentialHeadersFactory {
    func make(_ url: URL, method: RMSOAuthHTTPRequest.Method, parameters: RMSOAuth.Parameters, body: Data?) -> [String: String]
}

/// Allow to sign
// swiftlint:disable:next class_delegate_protocol
public protocol RMSOAuthSignatureDelegate {
    static func sign(hashMethod: RMSOAuthHashMethod, key: Data, message: Data) -> Data?
}

// The hash method used.
public enum RMSOAuthHashMethod: String {
    case sha1
    case none

    func hash(data: Data) -> Data? {
        switch self {
        case .sha1:
            let mac = SHA1(data).calculate()
            var hashedData: Data?
            mac.withUnsafeBufferPointer { pointer in
                guard let baseAddress = pointer.baseAddress else { return }
                hashedData = Data(bytes: baseAddress, count: mac.count)
            }
            return hashedData
        case .none:
            return data
        }
    }
}

/// The credential for authentification
open class RMSOAuthCredential: NSObject, NSSecureCoding, Codable {

    public static let supportsSecureCoding = true

    public enum Version: Codable {
        case oauth1, oauth2

        public var shortVersion: String {
            switch self {
            case .oauth1:
                return "1.0"
            case .oauth2:
                return "2.0"
            }
        }

        var toInt32: Int32 {
            switch self {
            case .oauth1:
                return 1
            case .oauth2:
                return 2
            }
        }

        init(_ value: Int32) {
            switch value {
            case 1:
                self = .oauth1
            case 2:
                self = .oauth2
            default:
                self = .oauth1
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.toInt32)
        }

        public init(from decoder: Decoder) throws {
            self.init(try decoder.singleValueContainer().decode(Int32.self))
        }
    }

    public enum SignatureMethod: String {
        case HMAC_SHA1 = "HMAC-SHA1"
        case RSA_SHA1 = "RSA-SHA1"
        case PLAINTEXT = "PLAINTEXT"

        public static var delegates: [SignatureMethod: RMSOAuthSignatureDelegate.Type] =
            [HMAC_SHA1: HMAC.self]

        var hashMethod: RMSOAuthHashMethod {
            switch self {
            case .HMAC_SHA1, .RSA_SHA1:
                return .sha1
            case .PLAINTEXT:
                return .none
            }
        }

        func sign(key: Data, message: Data) -> Data? {
            if let delegate = SignatureMethod.delegates[self] {
                return delegate.sign(hashMethod: self.hashMethod, key: key, message: message)
            }
            assert(self == .PLAINTEXT, "No signature method installed for \(self)")
            return message
        }

    }

    // MARK: attributes
    open internal(set) var clientID = ""
    open internal(set) var clientSecret = ""
    open var oauthToken = ""
    open var oauthRefreshToken = ""
    open var oauthTokenSecret = ""
    open var oauthTokenExpiresAt: Date?
    open internal(set) var oauthVerifier = ""
    open var version: Version = .oauth2
    open var signatureMethod: SignatureMethod = .HMAC_SHA1
    open var baseURL = ""

    /// hook to replace headers creation
    open var headersFactory: RMSOAuthCredentialHeadersFactory?

    // MARK: init
    override init() {
    }

    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }

    // MARK: NSCoding protocol
    fileprivate struct NSCodingKeys {
        static let bundleId = Bundle.main.bundleIdentifier
            ?? Bundle(for: RMSOAuthCredential.self).bundleIdentifier
            ?? ""
        static let base = bundleId + "."
        static let clientID = base + "comsumer_key"
        static let clientSecret = base + "consumer_secret"
        static let oauthToken = base + "oauth_token"
        static let oauthRefreshToken = base + "oauth_refresh_token"
        static let oauthTokenExpiresAt = base + "oauth_token_expires_at"
        static let oauthTokenSecret = base + "oauth_token_secret"
        static let oauthVerifier = base + "oauth_verifier"
        static let version = base + "version"
        static let signatureMethod = base + "signatureMethod"
        static let baseURL = base + "baseURL"
    }

    /// Cannot declare a required initializer within an extension.
    /// extension RMSOAuthCredential: NSCoding {
    public required convenience init?(coder decoder: NSCoder) {

        guard let clientID = decoder
            .decodeObject(of: NSString.self,
                          forKey: NSCodingKeys.clientID) as String? else {
            if #available(iOS 9, OSX 10.11, *) {
                let error = CocoaError.error(.coderValueNotFound)
                decoder.failWithError(error)
            }
            return nil
        }

        guard let clientSecret = decoder
            .decodeObject(of: NSString.self,
                          forKey: NSCodingKeys.clientSecret) as String? else {
            if #available(iOS 9, OSX 10.11, *) {
                let error = CocoaError.error(.coderValueNotFound)
                decoder.failWithError(error)
            }
            return nil
        }
        self.init(clientID: clientID, clientSecret: clientSecret)

        guard let oauthToken = decoder
            .decodeObject(of: NSString.self,
                          forKey: NSCodingKeys.oauthToken) as String? else {
            if #available(iOS 9, OSX 10.11, *) {
                let error = CocoaError.error(.coderValueNotFound)
                decoder.failWithError(error)
            }
            return nil
        }
        self.oauthToken = oauthToken

        guard let oauthRefreshToken = decoder
            .decodeObject(of: NSString.self,
                          forKey: NSCodingKeys.oauthRefreshToken) as String? else {
            if #available(iOS 9, OSX 10.11, *) {
                let error = CocoaError.error(.coderValueNotFound)
                decoder.failWithError(error)
            }
            return nil
        }
        self.oauthRefreshToken = oauthRefreshToken

        guard let oauthTokenSecret = decoder
            .decodeObject(of: NSString.self,
                          forKey: NSCodingKeys.oauthTokenSecret) as String? else {
            if #available(iOS 9, OSX 10.11, *) {
                let error = CocoaError.error(.coderValueNotFound)
                decoder.failWithError(error)
            }
            return nil
        }
        self.oauthTokenSecret = oauthTokenSecret

        guard let oauthVerifier = decoder
            .decodeObject(of: NSString.self,
                          forKey: NSCodingKeys.oauthVerifier) as String? else {
            if #available(iOS 9, OSX 10.11, *) {
                    let error = CocoaError.error(.coderValueNotFound)
                    decoder.failWithError(error)
            }
            return nil
        }
        self.oauthVerifier = oauthVerifier
        
        guard let baseURL = decoder
            .decodeObject(of: NSString.self,
                          forKey: NSCodingKeys.baseURL) as String? else {
            if #available(iOS 9, OSX 10.11, *) {
                let error = CocoaError.error(.coderValueNotFound)
                decoder.failWithError(error)
            }
            return nil
        }
        self.baseURL = baseURL

        self.oauthTokenExpiresAt = decoder
            .decodeObject(of: NSDate.self, forKey: NSCodingKeys.oauthTokenExpiresAt) as Date?
        self.version = Version(decoder.decodeInt32(forKey: NSCodingKeys.version))
        if case .oauth1 = version {
            self.signatureMethod = SignatureMethod(rawValue: (decoder.decodeObject(of: NSString.self, forKey: NSCodingKeys.signatureMethod) as String?) ?? "HMAC_SHA1") ?? .HMAC_SHA1
        }

        //RMSOAuth.log?.trace("Credential object is decoded")
    }

    open func encode(with coder: NSCoder) {
        coder.encode(self.clientID, forKey: NSCodingKeys.clientID)
        coder.encode(self.clientSecret, forKey: NSCodingKeys.clientSecret)
        coder.encode(self.oauthToken, forKey: NSCodingKeys.oauthToken)
        coder.encode(self.oauthRefreshToken, forKey: NSCodingKeys.oauthRefreshToken)
        coder.encode(self.oauthTokenSecret, forKey: NSCodingKeys.oauthTokenSecret)
        coder.encode(self.oauthVerifier, forKey: NSCodingKeys.oauthVerifier)
        coder.encode(self.oauthTokenExpiresAt, forKey: NSCodingKeys.oauthTokenExpiresAt)
        coder.encode(self.version.toInt32, forKey: NSCodingKeys.version)
        coder.encode(self.baseURL, forKey: NSCodingKeys.baseURL)
        if case .oauth1 = version {
            coder.encode(self.signatureMethod.rawValue, forKey: NSCodingKeys.signatureMethod)
        }
        //RMSOAuth.log?.trace("Credential object is encoded")

    }
    // } // End NSCoding extension

    // MARK: Codable protocol
    enum CodingKeys: String, CodingKey {
        case clientID
        case clientSecret
        case oauthToken
        case oauthRefreshToken
        case oauthTokenSecret
        case oauthVerifier
        case oauthTokenExpiresAt
        case version
        case signatureMethodRawValue
        case baseURL
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.clientID, forKey: .clientID)
        try container.encode(self.clientSecret, forKey: .clientSecret)
        try container.encode(self.oauthToken, forKey: .oauthToken)
        try container.encode(self.oauthRefreshToken, forKey: .oauthRefreshToken)
        try container.encode(self.oauthTokenSecret, forKey: .oauthTokenSecret)
        try container.encode(self.oauthVerifier, forKey: .oauthVerifier)
        try container.encodeIfPresent(self.oauthTokenExpiresAt, forKey: .oauthTokenExpiresAt)
        try container.encode(self.version, forKey: .version)
        if case .oauth1 = version {
            try container.encode(self.signatureMethod.rawValue, forKey: .signatureMethodRawValue)
        }
        //RMSOAuth.log?.trace("Credential object is encoded")

    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init()

        self.clientID = try container.decode(String.self, forKey: .clientID)
        self.clientSecret = try container.decode(String.self, forKey: .clientSecret)

        self.oauthToken = try container.decode(type(of: self.oauthToken), forKey: .oauthToken)
        self.oauthRefreshToken = try container.decode(type(of: self.oauthRefreshToken), forKey: .oauthRefreshToken)
        self.oauthTokenSecret = try container.decode(type(of: self.oauthTokenSecret), forKey: .oauthTokenSecret)
        self.oauthVerifier = try container.decode(type(of: self.oauthVerifier), forKey: .oauthVerifier)
        self.oauthTokenExpiresAt = try container.decodeIfPresent(Date.self, forKey: .oauthTokenExpiresAt)
        self.version = try container.decode(type(of: self.version), forKey: .version)
        self.baseURL = try container.decode(type(of: self.baseURL), forKey: .baseURL)

        if case .oauth1 = version {
            self.signatureMethod = SignatureMethod(rawValue: try container.decode(type(of: self.signatureMethod.rawValue), forKey: .signatureMethodRawValue))!
        }
    }

    // MARK: functions
    /// for OAuth1 parameters must contains sorted query parameters and url must not contains query parameters
    open func makeHeaders(_ url: URL, method: RMSOAuthHTTPRequest.Method, parameters: RMSOAuth.Parameters, body: Data? = nil) -> [String: String] {
        if let factory = headersFactory {
            return factory.make(url, method: method, parameters: parameters, body: body)
        }
        switch self.version {
        case .oauth1:
            return ["Authorization": self.authorizationHeader(method: method, url: url, parameters: parameters, body: body)]
        case .oauth2:
            return self.oauthToken.isEmpty ? [:] : ["Authorization": "Bearer \(self.oauthToken)"]
        }
    }

    open func authorizationHeader(method: RMSOAuthHTTPRequest.Method, url: URL, parameters: RMSOAuth.Parameters, body: Data? = nil) -> String {
        let timestamp = String(Int64(Date().timeIntervalSince1970))
        let nonce = RMSOAuthCredential.generateNonce()
        return self.authorizationHeader(method: method, url: url, parameters: parameters, body: body, timestamp: timestamp, nonce: nonce)
    }

    open class func generateNonce() -> String {
        let uuidString: String = UUID().uuidString
        return uuidString[0..<8]
    }

    open func authorizationHeader(method: RMSOAuthHTTPRequest.Method, url: URL, parameters: RMSOAuth.Parameters, body: Data? = nil, timestamp: String, nonce: String) -> String {
        assert(self.version == .oauth1)
        let authorizationParameters = self.authorizationParametersWithSignature(method: method, url: url, parameters: parameters, body: body, timestamp: timestamp, nonce: nonce)

        var parameterComponents = authorizationParameters.urlEncodedQuery.components(separatedBy: "&") as [String]
        parameterComponents.sort { $0 < $1 }

        var headerComponents = [String]()
        for component in parameterComponents {
            let subcomponent = component.components(separatedBy: "=") as [String]
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }

        //RMSOAuth.log?.trace("Authorization headers: \(headerComponents.joined(separator: ", "))")
        return "OAuth " + headerComponents.joined(separator: ", ")
    }

    open func authorizationParametersWithSignature(method: RMSOAuthHTTPRequest.Method, url: URL, parameters: RMSOAuth.Parameters, body: Data? = nil) -> RMSOAuth.Parameters {
        let timestamp = String(Int64(Date().timeIntervalSince1970))
        let nonce = RMSOAuthCredential.generateNonce()
        return self.authorizationParametersWithSignature(method: method, url: url, parameters: parameters, body: body, timestamp: timestamp, nonce: nonce)
    }

    open func authorizationParametersWithSignature(method: RMSOAuthHTTPRequest.Method, url: URL, parameters: RMSOAuth.Parameters, body: Data? = nil, timestamp: String, nonce: String) -> RMSOAuth.Parameters {
        var authorizationParameters = self.authorizationParameters(body, timestamp: timestamp, nonce: nonce)

        for (key, value) in parameters {
            if key.hasPrefix("oauth_") {
                authorizationParameters.updateValue(value, forKey: key)
            }
        }

        let combinedParameters = authorizationParameters.join(parameters)

        authorizationParameters["oauth_signature"] = self.signature(method: method, url: url, parameters: combinedParameters)

        return authorizationParameters
    }

    open func authorizationParameters(_ body: Data?, timestamp: String, nonce: String) -> RMSOAuth.Parameters {
        var authorizationParameters = RMSOAuth.Parameters()
        authorizationParameters["oauth_version"] = self.version.shortVersion
        authorizationParameters["oauth_signature_method"] =  self.signatureMethod.rawValue
        authorizationParameters["oauth_consumer_key"] = self.clientID
        authorizationParameters["oauth_timestamp"] = timestamp
        authorizationParameters["oauth_nonce"] = nonce
        if let b = body, let hash = self.signatureMethod.hashMethod.hash(data: b) {
            authorizationParameters["oauth_body_hash"] = hash.base64EncodedString(options: [])
        }

        if !self.oauthToken.isEmpty {
            authorizationParameters["oauth_token"] = self.oauthToken
        }
        return authorizationParameters
    }

    open func signature(method: RMSOAuthHTTPRequest.Method, url: URL, parameters: RMSOAuth.Parameters) -> String {
        let encodedTokenSecret = self.oauthTokenSecret.urlEncoded
        let encodedClientSecret = self.clientSecret.urlEncoded

        let signingKey = "\(encodedClientSecret)&\(encodedTokenSecret)"

        var parameterComponents = parameters.urlEncodedQuery.components(separatedBy: "&")
        parameterComponents.sort {
            let p0 = $0.components(separatedBy: "=")
            let p1 = $1.components(separatedBy: "=")
            if p0.first == p1.first { return p0.last ?? "" < p1.last ?? "" }
            return p0.first ?? "" < p1.first ?? ""
        }

        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.urlEncoded

        let encodedURL = url.absoluteString.urlEncoded

        guard self.signatureMethod != .PLAINTEXT else {
            return "\(encodedClientSecret)&\(encodedTokenSecret)"
        }

        let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"

        let key = signingKey.data(using: .utf8)!
        let msg = signatureBaseString.data(using: .utf8)!

        let sha1 = self.signatureMethod.sign(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }

    open func isTokenExpired() -> Bool {
        if let expiresDate = oauthTokenExpiresAt {
            return expiresDate <= Date()
        }

        // If no expires date is available we assume the token is still valid since it doesn't have an expiration date to check with.
        return false
    }

    // MARK: Equatable

    override open func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? RMSOAuthCredential else {
            return false
        }
        let lhs = self
        return lhs.clientID == rhs.clientID
            && lhs.clientSecret == rhs.clientSecret
            && lhs.oauthToken == rhs.oauthToken
            && lhs.oauthRefreshToken == rhs.oauthRefreshToken
            && lhs.oauthTokenSecret == rhs.oauthTokenSecret
            && lhs.oauthTokenExpiresAt == rhs.oauthTokenExpiresAt
            && lhs.oauthVerifier == rhs.oauthVerifier
            && lhs.version == rhs.version
            && lhs.signatureMethod == rhs.signatureMethod
            && lhs.baseURL == rhs.baseURL
    }

}
