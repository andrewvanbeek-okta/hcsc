//
//  UserRegViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/29/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import SwiftyPlistManager
import OktaAuth
import Eureka

class UserRegViewController: FormViewController, UITextFieldDelegate {
    
    @IBOutlet weak var regButton: UIButton!
    
    var localFn: String = ""
    var localLn: String = ""
    var localEmail: String = ""
    var localPwd: String = ""
    var localMem: String = ""
    var localPref: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupRegForm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Setup Registration Scroll View
    
    func setupRegForm() {
        
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.lightGray
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = true
        
        TextRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            cell.textField.textColor = row.isDisabled ? .gray : .white
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            } else {
                cell.titleLabel?.textColor = .white
            }
        }
        
        EmailRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
        }
        
        EmailRow.defaultCellUpdate = { cell, row in
            cell.textField.textColor = row.isDisabled ? .gray : .white
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            } else {
                cell.titleLabel?.textColor = .white
            }
        }
        
        PasswordRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
        }
        
        PasswordRow.defaultCellUpdate = { cell, row in
            cell.textField.textColor = row.isDisabled ? .gray : .white
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            } else {
                cell.titleLabel?.textColor = .white
            }
        }
        
        ActionSheetRow<String>.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
        }
        
        ActionSheetRow<String>.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = UIColor.white
        }
        
        form +++ Section()
            <<< TextRow("fnRow") {
                $0.title = "First Name"
                $0.placeholder = "John"
                $0.placeholderColor = .lightGray
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                }.onChange { row in
                    
                    if row.value != nil {
                        
                        self.localFn = row.value as String!
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "First Name is Required!"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            <<< TextRow("lnRow") {
                $0.title = "Last Name"
                $0.placeholder = "Smith"
                $0.placeholderColor = .lightGray
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                }.onChange { row in
                    
                    if row.value != nil {
                        
                        self.localLn = row.value as String!
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "Last Name is Required!"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            <<< EmailRow("emailRow") {
                $0.title = "Email"
                $0.placeholder = "john.smith@okta.com"
                $0.placeholderColor = .lightGray
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEmail())
                $0.validationOptions = .validatesOnDemand
                }.onChange { row in
                    
                    if row.value != nil {
                        
                        self.localEmail = row.value as String!
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "Email is Required!"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            <<< PasswordRow("pwdRow") {
                $0.title = "Password"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 7))
                $0.validationOptions = .validatesOnDemand
                }.onChange { row in
                    
                    if row.value != nil {
                        
                        self.localPwd = row.value as String!
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "Password length > 7"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            <<< PasswordRow("pwd2Row") {
                $0.title = "Confirm Password"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEqualsToRow(form: form, tag: "pwdRow"))
                $0.validationOptions = .validatesOnDemand
                }.onChange { row in
                    
                    if row.value != nil {
                        
                        self.localPwd = row.value as String!
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "Passwords Don't Match!"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            <<< ActionSheetRow <String>("memLvlRow") {
                $0.title = "Membership Level"
                $0.selectorTitle = "Select Your Membership Level"
                $0.options = ["Bronze","Silver","Gold","Platinum"]
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                }.onChange { row in
                    
                    if row.value != nil {
                        
                        self.localMem = row.value as String!
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "Membership Level is Required!"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            <<< ActionSheetRow <String> ("vehPrefRow") {
                $0.title = "Vehicle Preference"
                $0.selectorTitle = "Select Your Vehicle Preference"
                $0.options = ["Midsize","Offroad","Premium","SUV"]
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                }.onChange { row in
                    
                    if row.value != nil {
                        
                        self.localPref = row.value as String!
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = "Vehicle Preference is Required!"
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
    }
    
    // MARK: Register User Within Okta

    @IBAction func regButtonPressed(_ sender: Any) {
        
        form.validate()
        
        let fnRow = form.rowBy(tag: "fnRow")
        let lnRow = form.rowBy(tag: "lnRow")
        let emailRow = form.rowBy(tag: "emailRow")
        let pwdRow = form.rowBy(tag: "pwdRow")
        let pwd2Row = form.rowBy(tag: "pwd2Row")
        let memLvlRow = form.rowBy(tag: "memLvlRow")
        let vehPrefRow = form.rowBy(tag: "vehPrefRow")
        
        if isFormFieldValid(row: fnRow!) != true {
            return
        }
        if isFormFieldValid(row: lnRow!) != true {
            return
        }
        if isFormFieldValid(row: emailRow!) != true {
            return
        }
        if isFormFieldValid(row: pwdRow!) != true {
            return
        }
        if isFormFieldValid(row: pwd2Row!) != true {
            return
        }
        if isFormFieldValid(row: memLvlRow!) != true {
            return
        }
        if isFormFieldValid(row: vehPrefRow!) != true {
            return
        }
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()

        guard let fetchedGateway = SwiftyPlistManager.shared.fetchValue(for: "gateway", fromPlistWithName: "Okta") else {

            print("Gateway Required for Inventery Call.")
            generalAlert(titleTxt: "Gateway Required!", messageTxt: "Update settings and retry request.")
            return
        }

        let authNUrl = "\(fetchedGateway)/oktacarrental/v1/register"

        //print(authNUrl)

        guard let fetchedGatewayToken = SwiftyPlistManager.shared.fetchValue(for: "gatewayToken", fromPlistWithName: "Okta") else {

            print("Gateway Token Required for Inventery Call.")
            generalAlert(titleTxt: "Gateway Token Required!", messageTxt: "Update settings and retry request.")
            return
        }

        let headers = ["Authorization": "Bearer \(fetchedGatewayToken)"]
        
        let regReq = [

            "firstName": "\(localFn)",
            "lastName": "\(localLn)",
            "email": "\(localEmail)",
            "password": "\(localPwd)",
            "memLevel": "\(localMem)",
            "vehPref": "\(localPref)"
            ] as [String : Any]

        Alamofire.request(authNUrl, method: .post,
                          parameters: regReq,
                          encoding: JSONEncoding.default,
                          headers: headers).responseJSON { (response:DataResponse<Any>) in

                            //print("Request: \(String(describing: response.request))")
                            //print("Result: \(response.result)")

                            switch response.result {

                            case .success:

                                let json = JSON(response.result.value as Any)

                                if let userLogin = json["user_login"].string {

                                    HUD.flash(.success, delay: 1.0)
                                    self.generalAlertWithSegue(titleTxt: "Success Registration", messageTxt: "User \(userLogin) was created successfully")
                                }
                                
                                if let errorCode = json["error_code"].string {
                                    
                                    let errorMessage = json["error_message"].stringValue
                                    self.generalAlert(titleTxt: "Failed Registration", messageTxt: "\(errorCode) - \(errorMessage)")
                                    HUD.flash(.error, delay: 1.0)
                                }

                            case .failure(let error):

                                HUD.flash(.error, delay: 1.0)
                                self.generalAlert(titleTxt: "Error", messageTxt: "\(error)")
                            }


        }
    }
    
    // MARK: Helpers (Alerts, Keyboard, Segues)
    
    func isFormFieldValid(row: BaseRow) -> Bool {
        
        if row.isValid != true {
            
            return false
        }
        
        return true
    }
    
    //  General func to display alert messages (Requries passing of title and message text)
    
    func generalAlert(titleTxt: String, messageTxt: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        alert.title = titleTxt
        alert.message = messageTxt
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func generalAlertWithSegue(titleTxt: String, messageTxt: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default) { action in
                self.backButtonPress(self) })
        alert.title = titleTxt
        alert.message = messageTxt
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToCarViewFromReg", sender: self)
    }
}
