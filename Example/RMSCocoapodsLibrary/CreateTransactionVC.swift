//
//  CreateTransactionVC.swift
//  RMSExample
//
//  Created by Developer on 12/11/21.
//

import UIKit
import RMSCocoapodsLibrary

@available(iOS 13.0, *)
class CreateTransactionVC: UIViewController {
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var cashback: UITextField!
    var terminal : NSDictionary = [:];
    @IBOutlet weak var transView: UIView!
    @IBOutlet weak var transAmount: UILabel!
    @IBOutlet weak var transId: UILabel!
    @IBOutlet weak var transStage: UILabel!
    @IBOutlet weak var transType: UILabel!
    @IBOutlet weak var cashbackView: UIView!
    @IBOutlet weak var cashbackTransAmount: UILabel!
    @IBOutlet weak var cashbackTransId: UILabel!
    @IBOutlet weak var cashbackFinalAmount: UILabel!
    
    @IBOutlet weak var transStatus: UILabel!
    @IBOutlet weak var cashbackCashbackAmount: UILabel!
    @IBOutlet weak var cashbackTranType: UILabel!
    @IBOutlet weak var cashbackTransStage: UILabel!
    
    @IBOutlet weak var receiptCashBack: UIButton!
    @IBOutlet weak var receiptTrans: UIButton!
    @IBOutlet weak var cashbackTransStatus: UILabel!
    var transURL : String? = nil;
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Transaction";
        //print("create transaction:::::::",terminal);
        transView.isHidden = true;
        transView.layer.borderWidth = 0.5;
        transView.layer.borderColor = UIColor.gray.cgColor;
        cashbackView.isHidden = true;
        cashbackView.layer.borderWidth = 0.5;
        cashbackView.layer.borderColor = UIColor.gray.cgColor;
        amount.text = "0.00"
        cashback.text = "0.00"
    }
    func getAmount(amountValue : String) -> String {
        var amountText = amountValue
        let count = amountValue.count
        if count > 2 {
            let deciamlIndex = count - 2
            let suffixAmount = amountValue.suffix(2)
            let prefixAmount = amountValue.prefix(deciamlIndex)
            amountText = NSString.init(format: "%@.%@", prefixAmount as CVarArg,suffixAmount as CVarArg) as String
            let hasPerfix = amountText.hasPrefix("0")
            if hasPerfix {
                amountText.remove(at: amount.text!.startIndex)
            }
        }
        return amountText;
    }
    
    @IBAction func saleClicked(_ sender: Any) {
        self.receiptTrans.isHidden = true;
        self.receiptCashBack.isHidden = true;
        if amount.text == "0.00" {
            let alert = UIAlertController(title: "", message: "Please Enter Amount", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        cashbackView.isHidden = true;
        print(((terminal.value(forKey: "_links") as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href") as! NSString);
        let terminalURL = ((terminal.value(forKey: "_links") as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href") as! NSString;
        let params1 = NSMutableDictionary();
        let finalAmount =  amount.text?.replacingOccurrences(of: ".", with: "");
        params1["amount"] = Int(finalAmount!)
        params1["currency"] = "GBP"
        params1["transactionType"] = "SALE"

        let headers = NSMutableDictionary();
        headers["Accept"] = "*/*"
        headers["Content-Type"] = "application/json"
        headers["Connection"] = "keep-alive"
        appDelegate.rmsOAuth.client.post("\(terminalURL)/transaction", parameters: params1 as! RMSOAuth.Parameters, headers: (headers as! RMSOAuth.Headers), body: nil, completionHandler: { result in
            print("terminal result:::::::",result);
            switch result {
            case .success(let data):
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json::::::::",json!);
                        self.transView.isHidden = false;
                        self.cashbackView.isHidden = true;
                        self.amount.resignFirstResponder();
                        self.cashback.resignFirstResponder();
                        self.updateReceiptStatus(jsonValue: json!)
                    } catch {
                        print("Something went wrong")
                    }
                }
                
               
            case .failure(let error):
                print(error.localizedDescription);
//                let errorResponse: RMSOAuthError = error;
//                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
//                AlertPresenter().showAlert(message: "\(errorStatus)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTransaction400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rTransaction404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 409:
                    AlertPresenter().showAlert(message: .rTransaction409, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
       
    }
    
    @IBAction func refundClicked(_ sender: Any) {
        let finalAmount =  Int((amount.text?.replacingOccurrences(of: ".", with: ""))!);
        appDelegate.rmsOAuth.client.CreateTransaction(amount:finalAmount!, currency: "GBP", transactionType: "REFUND", completion: { result in
            switch result {
            case .success(let data):
              print("refundClicked success datadatadatadata:::::::",data)
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json::::::::",json!);
                        self.transView.isHidden = false;
                        self.cashbackView.isHidden = true;
                        self.amount.resignFirstResponder();
                        self.cashback.resignFirstResponder();
                        self.updateReceiptStatus(jsonValue: json!)
                    } catch {
                        print("Something went wrong")
                    }
                }
                
               
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTransaction400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rTransaction404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 409:
                    AlertPresenter().showAlert(message: .rTransaction409, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
    }
    @IBAction func cashbackClicked(_ sender: Any) {
        if amount.text == "0.00" {
            let alert = UIAlertController(title: "", message: "Please Enter Amount", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        else if cashback.text == "0.00" {
            let alert = UIAlertController(title: "", message: "Please Enter Cashback Amount", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        transView.isHidden = true;
        print(((terminal.value(forKey: "_links") as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href") as! NSString);
        let terminalURL = ((terminal.value(forKey: "_links") as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href") as! NSString;
        let params1 = NSMutableDictionary();
        let finalAmount =  amount.text?.replacingOccurrences(of: ".", with: "");
        let cashbackAmount =  cashback.text?.replacingOccurrences(of: ".", with: "");
        params1["amount"] = Int(finalAmount!)
        params1["currency"] = "GBP"
        params1["transactionType"] = "SALE"
        params1["amountCashback"] = Int(cashbackAmount!)
        

        let headers = NSMutableDictionary();
        headers["Accept"] = "*/*"
        headers["Content-Type"] = "application/json"
        headers["Connection"] = "keep-alive"
        appDelegate.rmsOAuth.client.post("\(terminalURL)/transaction", parameters: params1 as! RMSOAuth.Parameters, headers: (headers as! RMSOAuth.Headers), body: nil, completionHandler: { result in
            print("terminal result:::::::",result);
            switch result {
            case .success(let data):
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json::::::::",json!);
                        //print("transURLtransURLtransURLtransURL:: %@",self.transURL!);
                        self.transView.isHidden = true;
                        self.cashbackView.isHidden = false;
                        self.amount.resignFirstResponder();
                        self.cashback.resignFirstResponder();
                        self.updateReceiptStatus(jsonValue: json!)
                    } catch {
                        print("Something went wrong")
                    }
                }
                
               
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTransaction400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rTransaction404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 409:
                    AlertPresenter().showAlert(message: .rTransaction409, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
       
    }

    @IBAction func amountEditingChanged(_ sender: Any) {
        amount.text = amount.text?.replacingOccurrences(of: ".", with: "");
        if amount.text?.count == 1 {
            amount.text = NSString.init(format: ".0%@", amount.text!) as String
        }
        else if amount.text?.count == 2 {
            amount.text = NSString.init(format: "0.%@", amount.text!) as String
        }
        else
        {
            amount.text = self.getAmount(amountValue: amount.text!)
        }
    }
    
    @IBAction func cashbackEditingChanged(_ sender: Any) {
        cashback.text = cashback.text?.replacingOccurrences(of: ".", with: "");
        if cashback.text?.count == 1 {
            cashback.text = NSString.init(format: ".0%@", cashback.text!) as String
        }
        else if cashback.text?.count == 2 {
            cashback.text = NSString.init(format: "0.%@", cashback.text!) as String
        }
        else
        {
            cashback.text = self.getAmount(amountValue: cashback.text!)
        }
    }
    
    @IBAction func refreshStatus(_ sender: Any) {
        appDelegate.rmsOAuth.client.get(self.transURL!, completionHandler: { result in
            switch result {
            case .success(let data):
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json refreshStatus::::::::",json!)
                        self.updateReceiptStatus(jsonValue: json!)
                      
                    } catch {
                        print("Something went wrong")
                    }
                }
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTransaction400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rTransactionTrans404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 409:
                    AlertPresenter().showAlert(message: .rTransaction409, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 422:
                    AlertPresenter().showAlert(message: .rTransactionTrans422, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
        
    }
    @IBAction func cancelTransaction(_ sender: Any) {
        appDelegate.rmsOAuth.client.delete(self.transURL!, completionHandler: { result in
            switch result {
            case .success(let data):
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json cancelTransaction::::::::",json!)
                        self.updateReceiptStatus(jsonValue: json!)
                      
                    } catch {
                        print("Something went wrong")
                    }
                }
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTransaction400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rTransactionTrans404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 409:
                    AlertPresenter().showAlert(message: .rTransaction409, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 422:
                    AlertPresenter().showAlert(message: .rTransactionTrans422, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    AlertPresenter().showAlert(message: "\(errorResponse.localizedDescription)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
        
    }
    
    @IBAction func printReceipt(_ sender: Any) {
        appDelegate.rmsOAuth.client.get("\(self.transURL!)/ticket", completionHandler: { result in
            switch result {
            case .success(let data):
                let response: RMSOAuthResponse = data
                //print("data string:::::::::::",data.jsonObject)
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        print("json printReceipt::::::::",json!)
                        //self.updateReceiptStatus(jsonValue: json!)
                        AlertPresenter().showAlert(message: "\(json!)", confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                      
                    } catch {
                        print("Something went wrong")
                    }
                }
            case .failure(let error):
                print(error.localizedDescription);
                let errorResponse: RMSOAuthError = error;
                let errorStatus = errorResponse.errorUserInfo["statusCode"] as! Int;
                print("errorResponse.errorUserInfo",errorResponse.errorUserInfo)
                switch errorStatus {
                case 400:
                    AlertPresenter().showAlert(message: .rTransaction400, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 401:
                    AlertPresenter().showAlert(message: .rUnauthorize, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 404:
                    AlertPresenter().showAlert(message: .rTransactionTrans404, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 405:
                    AlertPresenter().showAlert(message: .rError405, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 409:
                    AlertPresenter().showAlert(message: .rTransaction409, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 422:
                    AlertPresenter().showAlert(message: .rTransactionTrans422, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                case 500:
                    AlertPresenter().showAlert(message: .rError500, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                default:
                    let errorMessage = errorResponse.errorUserInfo["statusMessage"] as! String;
                    AlertPresenter().showAlert(message: errorMessage, confirmTitle: "Dismiss", canceltitle: nil, onVc: self, confirmAction: nil, cancelAction: nil)
                }
            }
        })
        
    }
    
    func updateReceiptStatus(jsonValue : [String:Any]) {
        if !transView.isHidden
        {
            let amountString = jsonValue["amount"] ?? "";
            let amountText = self.getAmount(amountValue: NSString.init(format: "%@", amountString as! CVarArg) as String)
            self.transAmount.text = "Transaction Amount: \(amountText) GBP";
            self.transId.text = "Transaction Id: \(jsonValue["transactionRefId"] ?? "")";
            self.transStage.text = "Transaction Stage: \(jsonValue["transactionStage"]  ?? "")";
            self.transType.text = "Transaction Type: \(jsonValue["transactionType"] ?? "")";
            self.transStatus.text = "Transaction Status: \(jsonValue["transactionStatus"] ?? "-")";
            self.transURL = "\((((jsonValue["_links"] as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href")) ?? "")";
        }
        else
        {
            let amountString = jsonValue["amount"] ?? "";
            let amountText = self.getAmount(amountValue: NSString.init(format: "%@", amountString as! CVarArg) as String)
            let cashbackAmountString = jsonValue["amountCashback"] ?? "";
            let cashbackAmountText = self.getAmount(amountValue: NSString.init(format: "%@", cashbackAmountString as! CVarArg) as String)
            let finalAmountString = jsonValue["finalTransactionAmount"] ?? "";
            let finalAmountText = self.getAmount(amountValue: NSString.init(format: "%@", finalAmountString as! CVarArg) as String)
            self.cashbackTransAmount.text = "Transaction Amount: \(amountText) GBP";
            self.cashbackTransId.text = "Transaction Id: \(jsonValue["transactionRefId"] ?? "")";
            self.cashbackTransStage.text = "Transaction Stage: \(jsonValue["transactionStage"]  ?? "")";
            self.cashbackTranType.text = "Transaction Type: \(jsonValue["transactionType"] ?? "")";
            self.cashbackCashbackAmount.text = "Cashback Amount : \(cashbackAmountText) GBP";
            self.cashbackTransStatus.text = "Transaction Status: \(jsonValue["transactionStatus"] ?? "-")";
            self.cashbackFinalAmount.text = "Final Transaction Amount: \(finalAmountText) GBP";
            self.transURL = "\((((jsonValue["_links"] as! NSDictionary).value(forKey: "self") as! NSDictionary).value(forKey: "href")) ?? "")";
        }
        if "\(jsonValue["transactionStatus"] ?? "-")" == "SUCCESSFUL" {
            self.receiptTrans.isHidden = false;
            self.receiptCashBack.isHidden = false;
        }
        else
        {
            self.receiptTrans.isHidden = true;
            self.receiptCashBack.isHidden = true;
        }
    }
    
}

