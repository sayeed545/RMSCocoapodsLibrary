//
//  URL+RMSOAuth.swift
//  MainPOS
//
//  Created by Developer on 29/10/21.
//

import Foundation

extension URL {

    func urlByAppending(queryString: String) -> URL {
        if queryString.utf16.isEmpty {
            return self
        }

        var absoluteURLString = absoluteString

        if absoluteURLString.hasSuffix("?") {
            absoluteURLString.dropLast()
        }

        let string = absoluteURLString + (absoluteURLString.range(of: "?") != nil ? "&" : "?") + queryString

        return URL(string: string)!
    }

}
