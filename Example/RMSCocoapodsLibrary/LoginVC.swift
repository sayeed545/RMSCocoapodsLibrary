//
//  LoginVC.swift
//  RMSExample
//
//  Created by Developer on 10/11/21.
//

import UIKit
import RMSCocoapodsLibrary

@available(iOS 13.0, *)
class LoginVC: UIViewController {

    let scope = "rms/pos:read+rms/pos:write";
    //let redirectURL =  URL.init(string: "rmssdk://www.rmssdk.com/callback");
    let redirectURL =  URL.init(string: "kepos://");
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var activityView = UIActivityIndicatorView(activityIndicatorStyle: .large)
    
    @IBOutlet weak var loginbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad();
        appDelegate.rmsOAuth.allowMissingStateCheck = true;
        let defaults1 = UserDefaults.standard
        if let stringOne = defaults1.string(forKey: "refreshToken") {
            self.showActivityIndicatory();
            loginbutton.isHidden = true;
            appDelegate.rmsOAuth.renewAccessToken(withRefreshToken: stringOne, completionHandler: { result in
            print("result:::::::",result)
            switch result {
            case .success(let (credential, _, _)):
              print("result success refresh:::::::",credential.oauthToken)
                self.activityView.stopAnimating();
                self.activityView.removeFromSuperview();
                self.loginbutton.isHidden = false;
                let defaults = UserDefaults.standard
                defaults.set(credential.oauthToken, forKey: "accessToken");
                if let terminalvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminals") as? TerminalVC {
                    self.navigationController?.pushViewController(terminalvc, animated: true)
                }
                
            case .failure(let error):
                self.activityView.stopAnimating();
                self.activityView.removeFromSuperview();
                self.loginbutton.isHidden = false;
                print(error.localizedDescription)
            }
        })
        }
    }
    func showActivityIndicatory() {
       activityView.center = self.view.center
       self.view.addSubview(activityView)
       activityView.startAnimating()
   }
    @IBAction func setAuthorize(_ sender: Any) {
        appDelegate.rmsOAuth.authorize(withCallbackURL:  redirectURL, scope: scope, state: "", completionHandler: { result in
            print("result:::::::",result)
            switch result {
            case .success(let (credential, _, _)):
//              print("result success:::::::",credential.oauthToken)
//                print("result oauthRefreshToken success:::::::",credential.oauthRefreshToken);
                // Setting
                let defaults = UserDefaults.standard
                defaults.set(credential.oauthToken, forKey: "accessToken")
                defaults.set(credential.oauthRefreshToken, forKey: "refreshToken")
                //self.textView.text = String.init(format: "RMS Auth Success:\n\nAccess Token: %@",credential.oauthToken)
               // self.getTerminals(accessToken: credential.oauthToken);
              // Do your request
               // self.navigationController?.pushViewController(ViewController, animated: true)
                if let terminalvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminals") as? TerminalVC {
                    self.navigationController?.pushViewController(terminalvc, animated: true)
                    }
            case .failure(let error):
              print(error.localizedDescription)
            }
        })
    }

}

