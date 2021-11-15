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
              print(error.localizedDescription)
            }
        })
    }
    func getTerminals() {
        rmsOAuth.client.getTerminalList(completionHandler: { result in
            print("terminal result:::::::",result);
            switch result {
            case .success(let data):
              print("result success datadatadatadata:::::::",data)
                let response: RMSOAuthResponse = data
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json::::::::",json!["_embedded"] as Any)
                        if let appJson = json!["_embedded"] as? Dictionary<String, Any> {
                            print("appJsonappJsonappJsonappJsonappJson",appJson.count)
                            let results: NSArray = appJson["terminals"] as! NSArray

                            self.rmsOAuth.client.setActiveTerminal(terminal: results[0] as! NSDictionary)
                            self.rmsOAuth.client.CreateTransaction(amount: 2222, currency: "GBP", transactionType: "SALE", completion: { result2 in
                                print("CreateTransaction result:::::::",result2);
                                switch result2 {
                                case .success(let data2):
                                  print("result success datadatadatadata:::::::",data2)
                                    let response2: RMSOAuthResponse = data2
                                    let getresponse2 = response2.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

                                    if let data2 = getresponse2!.data(using: String.Encoding.utf8) {
                                        do {
                                            let json2 = try JSONSerialization.jsonObject(with: data2, options: .mutableContainers) as? [String:Any]
                                            print("CreateTransaction json2111::::::::",json2!);
                                            let transactionURL : NSString = "\(((json2!["_links"] as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href") as! NSString)" as NSString;
                                            let transArr = transactionURL.components(separatedBy: "/")
                                            print("transArr::: %@",transArr.last!)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                self.rmsOAuth.client.requestReportByType(type: "XBAL", completionHandler: { result2 in
                                                    switch result2 {
                                                    case .success(let data2):
                                                        let response2: RMSOAuthResponse = data2
                                                        let getresponse2 = response2.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

                                                        if let data2 = getresponse2!.data(using: String.Encoding.utf8) {
                                                            do {
                                                                let json2 = try JSONSerialization.jsonObject(with: data2, options: .mutableContainers) as? [String:Any]
                                                                print("requestReportByType json2222::::::::",json2!);

                                                               
                                                            } catch {
                                                                print("Something went wrong")
                                                            }
                                                        }

                                                    case .failure(let error):
                                                      print(error.localizedDescription)
                                                    }
                                                })
                                              
                                                
                                            }

                                           
                                        } catch {
                                            print("Something went wrong")
                                        }
                                    }

                                case .failure(let error):
                                  print(error.localizedDescription)
                                }
                            })

                            
                            
                        }
                    } catch {
                        print("Something went wrong")
                    }
                }

            case .failure(let error):
              print(error.localizedDescription)
            }
        })
//        rmsOAuth.client.get("https://api-terminal-dev1.retailmerchantservices.net/terminal", completionHandler: { result in
//            print("terminal result:::::::",result);
//            switch result {
//            case .success(let data):
//              print("result success datadatadatadata:::::::",data)
//                let response: RMSOAuthResponse = data
//                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//
//                if let data = getResponse!.data(using: String.Encoding.utf8) {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
//                        print("json::::::::",json!["_embedded"] as Any)
//
//                    } catch {
//                        print("Something went wrong")
//                    }
//                }
//
//            case .failure(let error):
//              print(error.localizedDescription)
//            }
//        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

