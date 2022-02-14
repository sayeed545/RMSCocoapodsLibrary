//
//  TerminalDetailVC.swift
//  RMSExample
//
//  Created by Developer on 17/11/21.
//

import UIKit
import RMSCocoapodsLibrary

@available(iOS 13.0, *)
class TerminalDetailVC: UIViewController {

    @IBOutlet weak var manufacturer: UILabel!
    @IBOutlet weak var terminalName: UILabel!
    @IBOutlet weak var pos: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var reportUpdate: UILabel!
    var terminal : NSDictionary = [:];
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Terminal Details";
        reportUpdate.isHidden = true;
        manufacturer.text = (terminal.value(forKey: "manufacturer") as! String)
        terminalName.text = (terminal.value(forKey: "terminalName") as! String)
        pos.text = (terminal.value(forKey: "pos") as! String)
        status.text = (terminal.value(forKey: "terminalStatus") as! String)
    }

    @IBAction func transactionListCalled(_ sender: Any) {
        reportUpdate.isHidden = true;
        if let transactionListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "transactionList") as? TransactionList {
            transactionListVC.terminal = terminal;
            self.navigationController?.pushViewController(transactionListVC, animated: true)
        }
    }
    @IBAction func reportXBAL(_ sender: Any) {
        reportUpdate.isHidden = true;
        appDelegate.rmsOAuth.client.requestReportByType(type: "XBAL", completionHandler: { result in
            print("TransactionList result:::::::",result);
            switch result {
            case .success( _):
                self.reportUpdate.isHidden = false;
                self.reportUpdate.text = "XBAL Report created successfully"
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rReport400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rReport404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
    }
    
    @IBAction func reportZBAL(_ sender: Any) {
        reportUpdate.isHidden = true;
        appDelegate.rmsOAuth.client.requestReportByType(type: "ZBAL", completionHandler: { result in
            print("TransactionList result:::::::",result);
            switch result {
            case .success( _):
                self.reportUpdate.isHidden = false;
                self.reportUpdate.text = "ZBAL Report created successfully"
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rReport400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rReport404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
    }
    
    @IBAction func reportEOD(_ sender: Any) {
        reportUpdate.isHidden = true;
        appDelegate.rmsOAuth.client.requestReportByType(type: "EOD", completionHandler: { result in
            print("TransactionList result:::::::",result);
            switch result {
            case .success( _):
                self.reportUpdate.isHidden = false;
                self.reportUpdate.text = "EOD Report created successfully"
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rReport400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rReport404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
    }
}
