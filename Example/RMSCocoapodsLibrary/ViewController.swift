//
//  ViewController.swift
//  RMSCocoapodsLibrary
//
//  Created by sayeed545 on 11/10/2021.
//  Copyright (c) 2021 sayeed545. All rights reserved.
//

import UIKit
import RMSCocoapodsLibrary
class ViewController: UIViewController {

    let rmsOAuth = RMSOAuth2(
        clientID:    "24srb04apnmiojprk37tjt1nup",
        clientSecret: "19q5c5jbprvsv30j66nnm7j4t5vlte3pfu516vkr1iiv8tpo38ng",
        authorizeUrl:   "https://api-auth-dev1.retailmerchantservices.net/oauth2/authorize",
        accessTokenUrl: "https://api-auth-dev1.retailmerchantservices.net/oauth2/token",
        responseType:   "code",
        baseURL: "https://api-terminal-dev1.retailmerchantservices.net"
    )
    let scope = "rms/pos:read+rms/pos:write";
    let redirectURL =  URL.init(string: "kepos://");
    override func viewDidLoad() {
        super.viewDidLoad();
        rmsOAuth.allowMissingStateCheck = true
        rmsOAuth.authorize(withCallbackURL:  redirectURL, scope: scope, state: "", completionHandler: { result in
            print("result:::::::",result)
            switch result {
            case .success(let (credential, _, _)):
//              print("result success:::::::",credential.oauthToken)
//                print("result oauthRefreshToken success:::::::",credential.oauthRefreshToken);
                // Setting
                let defaults = UserDefaults.standard
                defaults.set(credential.oauthToken, forKey: "accessToken")
                defaults.set(credential.oauthRefreshToken, forKey: "refreshToken")
                self.getTerminals()
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
    }
    func getTerminals() {
        rmsOAuth.client.get("https://api-terminal-sandbox.retailmerchantservices.net/terminal", completionHandler: { result in
            print("terminal result:::::::",result);
            switch result {
            case .success(let data):
              print("result success datadatadatadata:::::::",data)
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json::::::::",json!["_embedded"] as Any)
                       // let embedJson: Dictionary = json!
                        if let appJson = json!["_embedded"] as? Dictionary<String, Any> {
                            print("appJsonappJsonappJsonappJsonappJson",appJson.count)
                            let results: NSArray = appJson["terminals"] as! NSArray
                        }
                    } catch {
                        print("Something went wrong")
                    }
                }
              // Do your request
            case .failure(let error):
                //print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                print("error response",errorResponse);
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                print("error errorStatus",errorStatus);
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTerminal400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

