//
//  URLConvertible.swift
//  RMSOAuth
//
//  Created by Developer on 29/10/21.
//

import Foundation

/// Either a String representing URL or a URL itself
public protocol URLConvertible {
    var string: String { get }
    var url: URL? { get }
}

extension String: URLConvertible {
    public var string: String {
        return self
    }

    public var url: URL? {
        return URL(string: self)
    }
}

extension URL: URLConvertible {
    public var string: String {
        return absoluteString
    }

    public var url: URL? {
        return self
    }
}

extension URLConvertible {
    public var encodedURL: URL {
        return URL(string: self.string.urlEncoded)!
    }
}
