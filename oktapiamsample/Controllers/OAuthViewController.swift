//
//  OAuthViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 12/4/17.
//  Copyright © 2017 Joe Burgett. All rights reserved.
//

import UIKit
import OktaAuth
import SwiftyPlistManager
import PKHUD
import JWTDecode

class OAuthViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tokenSelectCollection: UICollectionView!
    @IBOutlet weak var tokenDetailTable: UITableView!
    
    @IBOutlet weak var tokenDetail: UILabel!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    
    @IBOutlet weak var authTime: UILabel!
    @IBOutlet weak var expTime: UILabel!
    
    var collectionArr: Array = [String]()
    var tokenTypes = ["Identity": "", "Access":"", "Refresh": ""]
    let loginType = [String] ()
    
    var tokenDetailData = [String: Any] ()
    let initTokenDetails = ["Login Needed": "Nothing to see here."]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        
        collectionArr = loginType
        
        
        self.tokenDetailTable.rowHeight = 125.0
        //tokenDetailData = initTokenDetails
        
        
        
        guard let fetchedIdToken = (OktaAuth.tokens?.get(forKey: "idToken")) else {
            
            generalAlert(titleTxt: "Identity Token Not Present!", messageTxt: "Please Login.")
            return
        }
        
        //idToken = fetchedIdToken
        self.tokenTypes.updateValue(fetchedIdToken, forKey: "Identity")
        self.collectionArr.append("Identity")
        
        guard let fetchedAcToken = (OktaAuth.tokens?.get(forKey: "accessToken")) else {
            
            generalAlert(titleTxt: "Access Token Not Present!", messageTxt: "Please Login.")
            return
        }
        
        //acToken = fetchedAcToken
        self.tokenTypes.updateValue(fetchedAcToken, forKey: "Access")
        self.collectionArr.append("Access")
        
        self.tokenDetailData =  self.decodeTokens(token: self.tokenTypes["Identity"]!)
        self.tokenDetail.text = "Identity Token Details"
        self.authTime.text = self.getFormattedTime(forTime: self.tokenDetailData["auth_time"] as! Double)
        self.expTime.text = self.getFormattedTime(forTime: self.tokenDetailData["exp"] as! Double)
        
    }
    
    // MARK: - Collection view data sources
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.collectionArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tokenSelectCell", for: indexPath) as! TokenSelectCollectionViewCell
        
        cell.tokenSelectCellLabel.text = self.collectionArr[indexPath.row]
        
        return cell
    }
    
    // MARK: - Collection view delegates
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = collectionView.cellForItem(at: indexPath) as! TokenSelectCollectionViewCell
        let currentLabel = currentCell.tokenSelectCellLabel.text!
        
        switch currentLabel {

        case "Identity":
            
//            // Testing enabling button on cell
//            currentCell.testButton.isEnabled = true
//            currentCell.testButton.alpha = 1.0
//            currentCell.testButton.addTarget(self, action: #selector(testButtonTapped), for: UIControlEvents.touchUpInside)
            
            let timeToExpire = self.getTimeRemaining(expireTime: self.tokenDetailData["exp"] as! Double)
            
            print("TESTING Time Remaining on ID Token:  \(timeToExpire)")
            
            self.tokenDetailData =  self.decodeTokens(token: self.tokenTypes["Identity"]!)
            self.tokenDetail.text = "\(currentLabel) Token Details"
            self.authLabel.text = "Auth Time"
            self.authTime.text = self.getFormattedTime(forTime: self.tokenDetailData["auth_time"] as! Double)
            self.expLabel.text = "Exp Time"
            self.expTime.text = self.getFormattedTime(forTime: self.tokenDetailData["exp"] as! Double)
            
            self.tokenDetailTable.reloadData()
            print("Identity Token")
        case "Access":
            
            let timeToExpire = self.getTimeRemaining(expireTime: self.tokenDetailData["exp"] as! Double)
            
            print("TESTING Time Remaining on Access Token:  \(timeToExpire)")
            
            self.tokenDetailData =  self.decodeTokens(token: self.tokenTypes["Access"]!)
            self.tokenDetail.text = "\(currentLabel) Token Details"
            self.authLabel.text = "Issue Time"
            self.authTime.text = self.getFormattedTime(forTime: self.tokenDetailData["iat"] as! Double)
            self.expLabel.text = "Exp Time"
            self.expTime.text = self.getFormattedTime(forTime: self.tokenDetailData["exp"] as! Double)
            
            self.tokenDetailTable.reloadData()
            print("Access Token")
        case "Refresh":
            
            self.tokenDetailData =  self.decodeTokens(token: self.tokenTypes["Refresh"]!)
            self.tokenDetail.text = "\(currentLabel) Token Details"
            self.authLabel.text = ""
            self.expLabel.text = ""
            self.authTime.text = ""
            self.expTime.text = ""
            self.tokenDetailTable.reloadData()
            print("Refresh Token")
        default:
        
            print("Nothing to do")
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tokenDetailData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tokenDetailCell", for: indexPath) as! TokenDetailTableViewCell
        
        var toDisplay : [(String, Any)] = []
        for (key, value) in self.tokenDetailData {
            
            toDisplay.append((key, value))
        }
        
        let (key, value) = toDisplay[indexPath.row]
        
        cell.tokenElementName?.text = key
        
        cell.tokenElementDetail?.text = stringFromAny(value)
        
        return cell
    }
    
    // MARK: Helpers (Formatters, Alerts, Decoders, Segues)
    
    func stringFromAny(_ value:Any?) -> String {
        
        if let arr = value, (arr is NSArray) {
            
            return (arr as! Array).joined(separator: ",")
        }

        if let nonNil = value, !(nonNil is NSNull) {
            return String(describing: nonNil)
        }
        return ""
    }
    
    //  General func to decode tokens.  JWTDecode is used to decode.
    
    func decodeTokens (token :String) -> Dictionary<String, Any>{
        
        do {
            let jwt = try decode(jwt: token)
            let jwtBody = jwt.body
            
            print(jwtBody)
            
            var jwtString = ""
            
            for (key,value) in jwtBody {
                
                jwtString.append("\(key) = \(value) \n")
            }
            
            return jwtBody
            
            
        } catch {
            
            print(error)
        }
        
        return ["Data": token]
    }
    
    //  General func to convert UNIX time for UI Display (Converted using device timezone)
    
    func getFormattedTime(forTime: Double) -> String {
        
        var localTimeZone: String { return TimeZone.current.abbreviation() ?? "" }
        
        let date = Date(timeIntervalSince1970: forTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZone)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    //  General func to calculate time remaining between Auth/Issue Time and Expire Token Time
    
    func getTimeRemaining(expireTime: Double) -> Double {
        
        let timeInterval = NSDate().timeIntervalSince1970
        
        let timeRemaining = expireTime - timeInterval
        
        return timeRemaining
    }
    
    //  General func to display alert messages (Requries passing of title and message text)
    
    func generalAlert(titleTxt: String, messageTxt: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        alert.title = titleTxt
        alert.message = messageTxt
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToCarViewFromOAuth", sender: self)
    }
}
