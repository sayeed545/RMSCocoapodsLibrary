//
//  ConstantString.swift
//  RMSCocoapodsLibrary
//
//  Created by sayeed545 on 03/02/22.
//  Copyright © 2022 sayeed545. All rights reserved.
//

import Foundation

extension String {
    
    public static let rUnauthorize = "Unauthorized"
    public static let rTerminal400 = "Please check your url."
    public static let rError500 = "Server is not working at the moment, please try again later."
    public static let rTerminalID400 = "Please check your terminal Id."
    public static let rTerminalID404 = "The requested terminal does not exist."
    public static let rReport400 = "Please check your terminal Id and report type."

    public static let rReport404 = "The requested terminal does not exist."
    public static let rTransaction400 = "Please check your terminal Id."
    public static let rTransaction404 = "The requested terminal does not exist."
    public static let rTransaction409 = "There is another transaction in progress."
    public static let rTransactionId400 = "Please check your terminal Id and transaction Id."
    public static let rTransactionTrans404 = "The requested transaction or terminal does not exist."
    public static let rTransactionTrans422 = "The transaction is already complete."
}
