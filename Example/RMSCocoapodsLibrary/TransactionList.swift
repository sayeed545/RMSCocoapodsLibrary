//
//  TransactionList.swift
//  RMSExample
//
//  Created by Developer on 15/11/21.
//

import UIKit
import RMSCocoapodsLibrary

@available(iOS 13.0, *)
class TransactionList: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    var terminal : NSDictionary = [:];
    var transURL : String? = nil;
    private var transactions: NSArray = []
    private var transactionList: UITableView!
    lazy var searchBar:UISearchBar = UISearchBar()
    var isSearch : Bool = false
    var filteredTableData: NSArray = []
    var transactionType : String? = "";
    var transactionStatus : String? = "";
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var saleImg: UIImageView!
    @IBOutlet weak var refundImg: UIImageView!
    @IBOutlet weak var successfulImg: UIImageView!
    @IBOutlet weak var referralImg: UIImageView!
    @IBOutlet weak var cancelUserImg: UIImageView!
    @IBOutlet weak var notSuccessImg: UIImageView!
    @IBOutlet weak var cancelPOSImg: UIImageView!
    @IBOutlet weak var revertPOSImg: UIImageView!
    @IBOutlet weak var timeoutImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Transaction List";
        let rightButtonItem = UIBarButtonItem.init(
              title: "Filter",
            style: .done,
              target: self,
            action: #selector(rightButtonAction)
        )

        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        searchBar = UISearchBar(frame: CGRect(x: 0, y: barHeight+44, width: displayWidth, height:44))
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search by Transaction Id"
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        transactionList = UITableView(frame: CGRect(x: 0, y: barHeight+98, width: displayWidth, height: displayHeight - barHeight-98))
        transactionList.register(TransactionTableCell.self, forCellReuseIdentifier: "MyCell")
        transactionList.dataSource = self
        transactionList.delegate = self
        self.view.addSubview(transactionList)
        self.view.addSubview(searchBar)
        self.getTransactionList();
    }
    func getTransactionList() {
        appDelegate.rmsOAuth.client.getTransactionList(completionHandler: { result in
            print("TransactionList result:::::::",result);
            switch result {
            case .success(let data):
                let response: RMSOAuthResponse = data
                let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

                if let data = getResponse!.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        if let appJson = json!["_embedded"] as? Dictionary<String, Any> {
                            let results: NSArray = appJson["transactions"] as! NSArray
                            print("transaction result:::::",results);
                         self.transactions = results;
                         self.transactionList.reloadData();
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
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        if self.sideView.isHidden {
            self.view.bringSubview(toFront: self.sideView)
            self.sideView.isHidden = false
            searchBar.resignFirstResponder()
            self.title = "Filter";
        }
        else
        {
            self.title = "Transaction List";
            self.sideView.isHidden = true
        }
    }
    func getAmount(amountValue : String) -> String {
        var amountText = amountValue
        let count = amountValue.count
        if count > 2 {
            let deciamlIndex = count - 2
            let suffixAmount = amountValue.suffix(2)
            let prefixAmount = amountValue.prefix(deciamlIndex)
            amountText = NSString.init(format: "%@.%@", prefixAmount as CVarArg,suffixAmount as CVarArg) as String
        }
        return amountText;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearch ? filteredTableData.count : transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let transaction: NSDictionary = isSearch ? filteredTableData[indexPath.row] as! NSDictionary : transactions[indexPath.row] as! NSDictionary;
        if transaction["finalTransactionAmount"] != nil
        {
            return 170.0
        }
        return 140.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
//        cell.textLabel!.text = "\(indexPath.row)"
//        return cell
        
        let transaction: NSDictionary = isSearch ? filteredTableData[indexPath.row] as! NSDictionary : transactions[indexPath.row] as! NSDictionary;
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! TransactionTableCell
        let amountString = transaction["amount"] ?? "";
        let amountText = self.getAmount(amountValue: NSString.init(format: "%@", amountString as! CVarArg) as String)
        if transaction["finalTransactionAmount"] != nil
        {
            let cashbackAmountString = transaction["amountCashback"] ?? "";
            let cashbackAmountText = self.getAmount(amountValue: NSString.init(format: "%@", cashbackAmountString as! CVarArg) as String)
            let finalAmountString = transaction["finalTransactionAmount"] ?? "";
            let finalAmountText = self.getAmount(amountValue: NSString.init(format: "%@", finalAmountString as! CVarArg) as String)
            cell.label.text = "Transaction Amount: \(amountText) GBP\nCashback  Amount: \(cashbackAmountText) GBP\nFinal Transaction Amount: \(finalAmountText) GBP\nTransaction Id: \(transaction.value(forKey: "transactionRefId") as! String)\nTransaction Stage: \(transaction.value(forKey: "transactionStage") as! String)\nTransaction Status: \(transaction.value(forKey: "transactionStatus") as! String)\nTransaction Type: \(transaction.value(forKey: "transactionType") as! String)";
        }
        else
        {
            cell.label.text = "Transaction Amount: \(amountText) GBP\nTransaction Id: \(transaction.value(forKey: "transactionRefId") as! String)\nTransaction Stage: \(transaction.value(forKey: "transactionStage") as! String)\nTransaction Status: \(transaction.value(forKey: "transactionStatus") as! String)\nTransaction Type: \(transaction.value(forKey: "transactionType") as! String)";
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.title = "Transaction List";
        sideView.isHidden = true;
    }
    
    //MARK: UISearchbar delegate
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            isSearch = true;
            self.title = "Transaction List";
            sideView.isHidden = true;
        }
           
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
               searchBar.resignFirstResponder()
               isSearch = false
        }
           
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
               searchBar.resignFirstResponder()
               isSearch = false
        }
           
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
               searchBar.resignFirstResponder()
               isSearch = false
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.count == 0 {
                isSearch = false
                self.transactionList.reloadData()
            } else {
                let filterPredicate = NSPredicate(format: "transactionRefId BEGINSWITH[c] %@", searchText)
                filteredTableData = transactions.filtered(using: filterPredicate) as NSArray
              
//                filteredTableData = transactions.filter({ (text) -> Bool in
//                    let tmp: NSString = text as NSString
//                    let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//                    return range.location != NSNotFound
//                })
                if(filteredTableData.count == 0){
                    isSearch = false
                } else {
                    isSearch = true
                }
                self.transactionList.reloadData()
            }
        }
    func updateTrasactionType(updateValue: Bool, index: Int) {
        if index == 1 && updateValue{
            self.transactionType = "SALE"
        }
        else if index == 2 && updateValue{
            self.transactionType = "REFUND"
        }
        else if !updateValue{
            self.transactionType = ""
        }
    }
    func updateTrasactionStatus(updateValue: Bool, index: Int) {
        if index == 3 && updateValue{
            self.transactionStatus = "SUCCESSFUL"
        }
        else if index == 4 && updateValue{
            self.transactionStatus = "REFERRAL"
        }
        else if index == 5 && updateValue{
            self.transactionStatus = "CANCELLED_BY_USER"
        }
        else if index == 6 && updateValue{
            self.transactionStatus = "NOT_SUCCESSFUL"
        }
        else if index == 7 && updateValue{
            self.transactionStatus = "CANCELLED_BY_POS"
        }
        else if index == 8 && updateValue{
            self.transactionStatus = "REVERTED_BY_POS"
        }
        else if index == 9 && updateValue{
            self.transactionStatus = "TIMEOUT"
        }
        else if !updateValue{
            self.transactionStatus = ""
        }
    }
    @IBAction func filterButtonCalled(sender: UIButton)
    {
        
        if sender.tag == 1 {
            self.updateTransactionImage(senderimg: saleImg, index: sender.tag)
        }
        else if sender.tag == 2 {
            self.updateTransactionImage(senderimg: refundImg, index: sender.tag)
        }
        else if sender.tag == 3 {
            self.updateStatusImage(senderimg: successfulImg, index: sender.tag)
        }
        else if sender.tag == 4 {
            self.updateStatusImage(senderimg: referralImg, index: sender.tag)
        }
        else if sender.tag == 5 {
            self.updateStatusImage(senderimg: cancelUserImg, index: sender.tag)
        }
        else if sender.tag == 6 {
            self.updateStatusImage(senderimg: notSuccessImg, index: sender.tag)
        }
        else if sender.tag == 7 {
            self.updateStatusImage(senderimg: cancelPOSImg, index: sender.tag)
        }
        else if sender.tag == 8 {
            self.updateStatusImage(senderimg: revertPOSImg, index: sender.tag)
        }
        else if sender.tag == 9 {
            self.updateStatusImage(senderimg: timeoutImg, index: sender.tag)
        }
        
    }
    func updateTransactionType(senderimg: UIImageView, index: Int)  {
        switch index {
        case 1:
            refundImg.image = UIImage(systemName: "square");
            self.transactionType = "SALE"
        case 2:
            saleImg.image = UIImage(systemName: "square");
            self.transactionType = "REFUND"
        default:
            refundImg.image = UIImage(systemName: "square");
            saleImg.image = UIImage(systemName: "square");
            self.transactionType = ""
        }
    }
    func updateTransactionStatus(senderimg: UIImageView, index: Int)  {
        switch index {
        case 3:
            referralImg.image = UIImage(systemName: "square");
            cancelUserImg.image = UIImage(systemName: "square");
            notSuccessImg.image = UIImage(systemName: "square");
            cancelPOSImg.image = UIImage(systemName: "square");
            revertPOSImg.image = UIImage(systemName: "square");
            timeoutImg.image = UIImage(systemName: "square");
            self.transactionStatus = "SUCCESSFUL"
        case 4:
            successfulImg.image = UIImage(systemName: "square");
            cancelUserImg.image = UIImage(systemName: "square");
            notSuccessImg.image = UIImage(systemName: "square");
            cancelPOSImg.image = UIImage(systemName: "square");
            revertPOSImg.image = UIImage(systemName: "square");
            timeoutImg.image = UIImage(systemName: "square");
            self.transactionStatus = "REFERRAL"
        case 5:
            referralImg.image = UIImage(systemName: "square");
            successfulImg.image = UIImage(systemName: "square");
            notSuccessImg.image = UIImage(systemName: "square");
            cancelPOSImg.image = UIImage(systemName: "square");
            revertPOSImg.image = UIImage(systemName: "square");
            timeoutImg.image = UIImage(systemName: "square");
            self.transactionStatus = "CANCELLED_BY_USER"
        case 6:
            referralImg.image = UIImage(systemName: "square");
            cancelUserImg.image = UIImage(systemName: "square");
            successfulImg.image = UIImage(systemName: "square");
            cancelPOSImg.image = UIImage(systemName: "square");
            revertPOSImg.image = UIImage(systemName: "square");
            timeoutImg.image = UIImage(systemName: "square");
            self.transactionStatus = "NOT_SUCCESSFUL"
        case 7:
            referralImg.image = UIImage(systemName: "square");
            cancelUserImg.image = UIImage(systemName: "square");
            notSuccessImg.image = UIImage(systemName: "square");
            successfulImg.image = UIImage(systemName: "square");
            revertPOSImg.image = UIImage(systemName: "square");
            timeoutImg.image = UIImage(systemName: "square");
            self.transactionStatus = "CANCELLED_BY_POS"
        case 8:
            referralImg.image = UIImage(systemName: "square");
            cancelUserImg.image = UIImage(systemName: "square");
            notSuccessImg.image = UIImage(systemName: "square");
            cancelPOSImg.image = UIImage(systemName: "square");
            successfulImg.image = UIImage(systemName: "square");
            timeoutImg.image = UIImage(systemName: "square");
            self.transactionStatus = "REVERTED_BY_POS"
        case 9:
            referralImg.image = UIImage(systemName: "square");
            cancelUserImg.image = UIImage(systemName: "square");
            notSuccessImg.image = UIImage(systemName: "square");
            cancelPOSImg.image = UIImage(systemName: "square");
            revertPOSImg.image = UIImage(systemName: "square");
            successfulImg.image = UIImage(systemName: "square");
            self.transactionStatus = "TIMEOUT"
        default:
            successfulImg.image = UIImage(systemName: "square");
            referralImg.image = UIImage(systemName: "square");
            cancelUserImg.image = UIImage(systemName: "square");
            notSuccessImg.image = UIImage(systemName: "square");
            cancelPOSImg.image = UIImage(systemName: "square");
            revertPOSImg.image = UIImage(systemName: "square");
            timeoutImg.image = UIImage(systemName: "square");
            self.transactionStatus = ""
        }
    }
    func updateTransactionImage(senderimg: UIImageView, index: Int){
        if (senderimg.image?.isEqual(UIImage(systemName: "square")))! {
            senderimg.image = UIImage(systemName: "checkmark.square.fill");
            self.updateTransactionType(senderimg: senderimg, index: index)
        }
        else
        {
            senderimg.image = UIImage(systemName: "square");
            self.transactionType = ""
        }
    }
    func updateStatusImage(senderimg: UIImageView, index: Int){
        if (senderimg.image?.isEqual(UIImage(systemName: "square")))! {
            senderimg.image = UIImage(systemName: "checkmark.square.fill");
            self.updateTransactionStatus(senderimg: senderimg, index: index)
            
        }
        else
        {
            senderimg.image = UIImage(systemName: "square");
            self.transactionStatus = ""
        }
    }
    @IBAction func filterSearchClicked(_ sender: Any) {
        self.title = "Transaction List";
        sideView.isHidden = true;
        self.transactions = [];
        self.transactionList.reloadData();
        appDelegate.rmsOAuth.client.getTransactionListByAll(transactionType: self.transactionType!, transactionStage: "", transactionStatus: self.transactionStatus!, parameters: [:], headers: nil, completionHandler: { result in
                switch result {
                case .success(let data):
                    let response: RMSOAuthResponse = data
                    let getResponse = response.dataString(encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    print("check getResponse:::::",getResponse as Any)
                    if let data = getResponse!.data(using: String.Encoding.utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                            if let appJson = json!["_embedded"] as? Dictionary<String, Any> {
                                let results: NSArray = appJson["transactions"] as! NSArray
                                print("transaction result:::::",results);
                             self.transactions = results;
                             self.transactionList.reloadData();
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
    @IBAction func filterResetClicked(_ sender: Any) {
        saleImg.image = UIImage(systemName: "square");
        refundImg.image = UIImage(systemName: "square");
        successfulImg.image = UIImage(systemName: "square");
        referralImg.image = UIImage(systemName: "square");
        cancelUserImg.image = UIImage(systemName: "square");
        notSuccessImg.image = UIImage(systemName: "square");
        cancelPOSImg.image = UIImage(systemName: "square");
        revertPOSImg.image = UIImage(systemName: "square");
        timeoutImg.image = UIImage(systemName: "square");
        sideView.isHidden = true;
        self.getTransactionList();
        
    }
    
}


class TransactionTableCell: UITableViewCell {
    var label = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 0.5
        label = UILabel(frame: CGRect(x: 10, y: 0, width: 400, height: 160))
        //label.center = CGPoint(x: 160, y: 40)
        label.textAlignment = .left
        label.numberOfLines = 7
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.backgroundColor = .white
        label.text = "-"
       
        contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
