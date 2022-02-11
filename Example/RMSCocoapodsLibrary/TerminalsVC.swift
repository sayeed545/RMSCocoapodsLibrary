//
//  TerminalsVC.swift
//  RMSExample
//
//  Created by Developer on 10/11/21.
//

import UIKit
import RMSCocoapodsLibrary

@available(iOS 13.0, *)
class TerminalVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var terminals: NSArray = []
    private var terminalList: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true);
        self.title = "List of Terminals";
        let rightButtonItem = UIBarButtonItem.init(
              title: "Logout",
            style: .done,
              target: self,
            action: #selector(rightButtonAction)
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
        let leftButtonItem = UIBarButtonItem.init(
              title: "Reload",
            style: .done,
              target: self,
            action: #selector(reloadAction)
        )

        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.getTerminals();
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height

        terminalList = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        //terminalList.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        terminalList.register(CustomTableCell.self, forCellReuseIdentifier: "MyCell")
        terminalList.dataSource = self
        terminalList.delegate = self
        self.view.addSubview(terminalList)

        
    }
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
                    for cookie in cookies {
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }
                }
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "accessToken");
        defaults.set("", forKey: "refreshToken");
        
    }
    @objc func reloadAction(sender: UIBarButtonItem) {
        self.getTerminals();
    }
    
    func getTerminals() {
        appDelegate.rmsOAuth.client.getTerminalList(completionHandler: { result in
            switch result {
            case .success(let data):
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        if let appJson = json!["_embedded"] as? Dictionary<String, Any> {
                            let results: NSArray = appJson["terminals"] as! NSArray
                         self.terminals = results;
                         print("self.terminals::::::",self.terminals);
                         self.terminalList.reloadData();

                            
                            
                        }
                    } catch {
                        print("Something went wrong")
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTerminal400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
                
            }
        })
       
   }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("Num: \(indexPath.row)")
            print("Value: \(terminals[indexPath.row])")
        appDelegate.rmsOAuth.client.setActiveTerminal(terminal: terminals[indexPath.row] as! NSDictionary);
        if let terminalDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminaldetail") as? TerminalDetailVC {
            terminalDetailVC.terminal = terminals[indexPath.row] as! NSDictionary;
            self.navigationController?.pushViewController(terminalDetailVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terminals.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let terminal: NSDictionary = terminals[indexPath.row] as! NSDictionary;
        print("terminal::::::::::::::::::::::::::",terminal);
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! CustomTableCell
        cell.createTransc.addTarget(self, action: #selector(creatTransaction), for: .touchUpInside)
        cell.createTransc.tag = indexPath.row
        cell.data =  terminal;
        cell.label.text = "Manufacturer: \(terminal.value(forKey: "manufacturer") as! String)\nTerminal Name: \(terminal.value(forKey: "terminalName") as! String)\nPOS: \(terminal.value(forKey: "pos") as! String)\nStatus: \(terminal.value(forKey: "terminalStatus") as! String)";
        return cell
    }
    @objc func creatTransaction(sender:UIButton)
    {
        appDelegate.rmsOAuth.client.setActiveTerminal(terminal: terminals[sender.tag] as! NSDictionary);
        if let createTransactionvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createtransaction") as? CreateTransactionVC {
            createTransactionvc.terminal = terminals[sender.tag] as! NSDictionary;
            self.navigationController?.pushViewController(createTransactionvc, animated: true)
        }
        
    }


}

class CustomTableCell: UITableViewCell {
    var data = NSDictionary()
    var label = UILabel()
    var createTransc = UIButton()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("datadatadata:::::::",data);
        contentView.backgroundColor = .white
        let buttonColor : UIColor = UIColor(red: 0, green: 114/255, blue: 227/255, alpha: 1.0)
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 0.5
        label = UILabel(frame: CGRect(x: 10, y: 0, width: 400, height: 100))
        //label.center = CGPoint(x: 160, y: 40)
        label.textAlignment = .left
        label.numberOfLines = 4
        label.backgroundColor = .white
        label.text = "I'm a test label\nI'm a test label\nI'm a test label\nI'm a test label"
        createTransc = UIButton(frame: CGRect(x: 10, y: 110, width: 400, height: 40))
        createTransc.contentHorizontalAlignment = .center
        createTransc.backgroundColor = buttonColor
        createTransc.setTitle("CREATE TRANSACTION", for: .normal)
        contentView.addSubview(label)
        contentView.addSubview(createTransc)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

