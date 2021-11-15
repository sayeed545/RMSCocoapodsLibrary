//
//  RMSOAuth.swift
//  RMSOAuth
//
//  Created by Developer on 29/10/21.
//

import Foundation

public class RMSOAuth: NSObject, RMSOAuthRequestHandle {

    // MARK: Properties

    /// Client to make signed request
    open var client: RMSOAuthClient
    /// Version of the protocol
    open var version: RMSOAuthCredential.Version { return self.client.credential.version }

    /// Handle the authorize url into a web view or browser
    open var authorizeURLHandler: RMSOAuthURLHandlerType = RMSOAuthURLHandlerTypeFactory.default

    fileprivate var currentRequests: [String: RMSOAuthRequestHandle] = [:]

    // MARK: init
    init(clientID: String, clientSecret: String) {
        self.client = RMSOAuthClient(clientID: clientID, clientSecret: clientSecret)
    }

    // MARK: callback notification
    struct CallbackNotification {
        static let optionsURLKey = "RMSOAuthCallbackNotificationOptionsURLKey"
    }

    /// Handle callback url which contains now token information
    open class func handle(url: URL) {
        let notification = Notification(name: RMSOAuth.didHandleCallbackURL, object: nil,
            userInfo: [CallbackNotification.optionsURLKey: url])
        notificationCenter.post(notification)
    }

    var observer: NSObjectProtocol?
    open class var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    open class var notificationQueue: OperationQueue {
        return OperationQueue.main
    }

    func observeCallback(_ block: @escaping (_ url: URL) -> Void) {
        self.observer = RMSOAuth.notificationCenter.addObserver(
            forName: RMSOAuth.didHandleCallbackURL,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                self?.removeCallbackNotificationObserver()

            if let urlFromUserInfo = notification.userInfo?[CallbackNotification.optionsURLKey] as? URL {
                block(urlFromUserInfo)
            } else {
                // Internal error
                assertionFailure()
            }
        }
    }

    /// Remove internal observer on authentification
    public func removeCallbackNotificationObserver() {
        if let observer = self.observer {
            RMSOAuth.notificationCenter.removeObserver(observer)
            self.observer = nil
        }
    }

    /// Function to call when web view is dismissed without authentification
    public func cancel() {
        self.removeCallbackNotificationObserver()
        for (_, request) in self.currentRequests {
            request.cancel()
        }
        self.currentRequests = [:]
    }

    func putHandle(_ handle: RMSOAuthRequestHandle, withKey key: String) {
        // self.currentRequests[withKey] = handle
        // TODO before storing handle, find a way to remove it when network request end (ie. all failure and success ie. complete)
    }

    /// Run block in main thread
    static func main(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }

}

// MARK: - alias
public extension RMSOAuth {

     typealias Parameters = [String: Any]
     typealias Headers = [String: String]
     typealias ConfigParameters = [String: String]
    // MARK: callback alias
     typealias TokenSuccess = (credential: RMSOAuthCredential, response: RMSOAuthResponse?, parameters: Parameters)
     typealias TokenCompletionHandler = (Result<TokenSuccess, RMSOAuthError>) -> Void
     typealias TokenRenewedHandler = (Result<RMSOAuthCredential, Never>) -> Void

}


