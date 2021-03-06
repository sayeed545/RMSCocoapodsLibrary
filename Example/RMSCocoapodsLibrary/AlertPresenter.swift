//
//  AlertPresenter.swift
//  RMSCocoapodsLibrary
//
//  Created by RMSCocoapodsLibrary on 03/02/22.
//  Copyright © 2022 RMSCocoapodsLibrary. All rights reserved.
//

import Foundation
import UIKit
class AlertPresenter {
    
    func showAlert(title:String? = "RMS",message:String,confirmTitle:String? = "OK", canceltitle:String? = nil,onVc:UIViewController,confirmAction:((UIAlertAction) -> Void)? = nil, cancelAction:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let confirm  = confirmTitle {
            let confirmButton = UIAlertAction(title: confirm, style: .default, handler:confirmAction)
            alert.addAction(confirmButton)
        }
        if let cancel = canceltitle {
            let dismissAction = UIAlertAction(title: cancel, style: .default, handler: cancelAction)
            alert.addAction(dismissAction)
        }
        onVc.present(alert, animated: true, completion: nil)
    }
    
    func showOfflineError(onVc:UIViewController){
        
        self.showAlert(message: "The Internet connection appears to be offline.", onVc: onVc)
        
    }
    
}
