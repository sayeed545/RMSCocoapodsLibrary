//
//  RMSOAuthURLHandlerType.swift
//  MainPOS
//
//  Created by Developer on 29/10/21.
//

import Foundation


#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(OSX)
import AppKit
#endif

/// Protocol to defined how to open the url.
/// You could choose to open using an external browser, a safari controller, an internal webkit view controller, etc...
@objc public protocol RMSOAuthURLHandlerType {
    func handle(_ url: URL)
}

public struct RMSOAuthURLHandlerTypeFactory {

    static var `default`: RMSOAuthURLHandlerType = RMSOAuthOpenURLExternally.sharedInstance
}
