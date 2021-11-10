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
        responseType:   "code"
    )
    let scope = "rms/pos:read+rms/pos:write";
    let redirectURL =  URL.init(string: "kepos://");
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

