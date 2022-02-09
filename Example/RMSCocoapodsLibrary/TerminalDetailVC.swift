//
//  TerminalDetailVC.swift
//  RMSExample
//
//  Created by Developer on 17/11/21.
//

import UIKit

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
              print(error.localizedDescription)
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
              print(error.localizedDescription)
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
              print(error.localizedDescription)
            }
        })
    }
}
