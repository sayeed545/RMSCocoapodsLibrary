//
//  RMSOAuthOpenURLExternally.swift
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

/// Open externally using open url application function.
open class RMSOAuthOpenURLExternally: RMSOAuthURLHandlerType {

    public static var sharedInstance: RMSOAuthOpenURLExternally = RMSOAuthOpenURLExternally()

    @objc open func handle(_ url: URL) {
        #if os(iOS) || os(tvOS)
        #if !OAUTH_APP_EXTENSIONS
        if #available(iOS 10.0, tvOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
        #endif
        #elseif os(watchOS)
        // WATCHOS: not implemented
        #elseif os(OSX)
        NSWorkspace.shared.open(url)
        #endif
    }
}
