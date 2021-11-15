//
//  NotificationCenter+RMSOAuth.swift
//  RMSOAuth
//
//  Created by Developer on 29/10/21.
//

import Foundation

public extension Notification.Name {
    @available(*, deprecated, renamed: "RMSOAuth.didHandleCallbackURL")
    static let RMSOAuthHandleCallbackURL: Notification.Name = RMSOAuth.didHandleCallbackURL
}
public extension RMSOAuth {
    static let didHandleCallbackURL: Notification.Name = .init("RMSOAuthCallbackNotificationName")
}
