//
//  ConfigViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 11/29/17.
//  Copyright © 2017 Joe Burgett. All rights reserved.
//

import UIKit
import Eureka
import SwiftyPlistManager

class ConfigViewController: FormViewController {
    
    // Form variables
    
    var sectionHeaderHeight = CGFloat();
    
    // Local variables - Cleanup needed
    
    var localIssuer: String = ""
    var localClientId: String = ""
    var localRedirect: String = ""
    var localDefScopes: String = ""
    var localCustomScopes: Array = [String]()
    var localGateway: String = ""
    var localGatewayToken: String = ""
    
    //  Switchs to Control Setup of Config Screen (Populate with current scopes)
    
    var localOpenIdSwitch: Bool = false
    var localProfileSwitch: Bool = false
    var localEmailSwitch: Bool = false
    var localAddressSwitch: Bool = false
    var localPhoneSwitch: Bool = false
    var localOfflineSwitch: Bool = false
    var localVechiclesSwitch: Bool = false
    var localBookSwitch: Bool = false
    
    // Variables used to understand scopes to save
    var scopesToSave: Dictionary = [String: Bool]()
    var localScopes : Array = [String]()
    
    // Variable used to control the number of allowable custom scopes
    var localCustomCount : Int = 5
    
    var localFormValues: Dictionary = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Pull current configuration values
        returnOktaValues()
        
        // Build Configuration form and set initial values
        buildConfigForms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Retrieve Current Configuration
    
    func returnOktaValues() {
        
        guard let fetchedScopes = SwiftyPlistManager.shared.fetchValue(for: "scopes", fromPlistWithName: "Okta") else { return }
        guard let fetchedClientId = SwiftyPlistManager.shared.fetchValue(for: "clientId", fromPlistWithName: "Okta") else { return }
        guard let fetchedIssuer = SwiftyPlistManager.shared.fetchValue(for: "issuer", fromPlistWithName: "Okta") else { return }
        guard let fetchedRedirect = SwiftyPlistManager.shared.fetchValue(for: "redirectUri", fromPlistWithName: "Okta") else { return }
        guard let fetchedGateway = SwiftyPlistManager.shared.fetchValue(for: "gateway", fromPlistWithName: "Okta") else { return }
        guard let fetchedGatewayToken = SwiftyPlistManager.shared.fetchValue(for: "gatewayToken", fromPlistWithName: "Okta") else { return }
        
        
        let scopesArray = (fetchedScopes as! NSArray) as NSArray
        //print("\n********** TOBE FORM VALUES **********")
        //print(scopesArray)
        
        for scope in scopesArray {
            
            switch scope as! String {
                
            case "openid":
                
                self.localOpenIdSwitch = true
                localFormValues["openid"] = "openid"
            case "profile":
                
                self.localProfileSwitch = true
                localFormValues["profile"] = "profile"
            case "email":
                
                self.localEmailSwitch = true
                localFormValues["email"] = "email"
            case "address":
                
                self.localAddressSwitch = true
                localFormValues["address"] = "address"
            case "phone":
                
                self.localPhoneSwitch = true
                localFormValues["phone"] = "phone"
            case "offline_access":
                
                self.localOfflineSwitch = true
                localFormValues["offline_access"] = "offline_access"
            case "https://oktacarrental.com/vehicles.read":
                
                self.localVechiclesSwitch = true
                localFormValues["https://oktacarrental.com/vehicles.read"] = "https://oktacarrental.com/vehicles.read"
            case "https://oktacarrental.com/book":
                
                self.localBookSwitch = true
                localFormValues["https://oktacarrental.com/book"] = "https://oktacarrental.com/book"
            default:
                //print("NOT A DEFAULT SCOPE")
                localCustomScopes.insert(scope as! String, at: 0)
                //print("\n********** LOCAL CUSTOM SCOPES VALUES ARRAY **********")
                //print(localCustomScopes)
            }
            
        }
        
        if localCustomScopes.count >= 1 {
            var whileCount = localCustomScopes.count
            var currentCustoms = localCustomScopes
            
            while whileCount >= 1 {
                
                
                let custom2Screen = currentCustoms.popLast()
                
                localFormValues["Custom\(whileCount)"] = custom2Screen
                
                whileCount -= 1
            }
        }
        
        //print("*\n********* LOCAL CUSTOM SCOPES VALUES ARRAY **********")
        //print(localCustomScopes)
        
        //print("\n********** LOCAL FORM VALUES DICTIONARY **********")
        //print(localFormValues)
        
        localClientId = fetchedClientId as! String
        localIssuer = fetchedIssuer as! String
        localRedirect = fetchedRedirect as! String
        localGateway = fetchedGateway as! String
        localGatewayToken = fetchedGatewayToken as! String
        
        localFormValues["issuerRow"] = localIssuer
        localFormValues["clientIdRow"] = localClientId
        localFormValues["redirectRow"] = localRedirect
    }
    
    // MARK: - Build and Populate Configuration Form
    
    func buildConfigForms() {
        
        self.tableView?.backgroundView = UIImageView(image: UIImage(named: "Background.png"))
        //self.tableView?.isScrollEnabled = false
        
        self.sectionHeaderHeight = 60
        
        TextRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = .white
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            cell.textField.textColor = row.isDisabled ? .gray : .black
        }
        
        form
            //+++ Section("Okta OpenID App Information")
            +++ Section() {
                var header = HeaderFooterView<EurekaLogoViewNib>(.nibFile(name: "ConfigHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 0;
                    UIView.animate(withDuration: 1.5, animations: { [weak view] in
                        view?.imageView.alpha = 1
                    })
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 0.8, animations: { [weak view] in
                        view?.layer.transform = CATransform3DIdentity
                    })
                }
                $0.header = header
                }
            
            +++ Section("Okta OpenID App Information")
            
            <<< TextRow(){ row in
                row.title = "Issuer"
                row.placeholder = "Ex. https://org.okta.com"
                row.tag = "issuerRow"
                row.value = self.localIssuer
                }.cellSetup { cell, row in
                    cell.backgroundView?.backgroundColor = UIColor.gray
                }.onChange { row in
                    // Guard against empty field
                    guard let iss = row.value else {
                        row.value = ""
                        return
                    }
                    // If value present then set local
                    self.localIssuer = iss
                }
            
            <<< TextRow(){
                $0.title = "Client ID"
                $0.placeholder = "App Client ID"
                $0.tag = "clientIdRow"
                $0.value = self.localClientId
                }.cellSetup { cell, row in
                    cell.backgroundView?.backgroundColor = UIColor.gray
                }.onChange { row in
                    // Guard against empty field
                    guard let cid = row.value else {
                        row.value = ""
                        return
                    }
                    // If value present then set local
                    self.localClientId = cid
                }
            
            <<< TextRow(){
                $0.title = "Gateway"
                $0.placeholder = "gateway.com"
                $0.tag = "gatewayRow"
                $0.value = self.localGateway
                }.cellSetup { cell, row in
                    cell.backgroundView?.backgroundColor = UIColor.gray
                }.onChange { row in
                    // Guard against empty field
                    guard let cid = row.value else {
                        row.value = ""
                        return
                    }
                    // If value present then set local
                    self.localGateway = cid
            }
            
            <<< TextRow(){
                $0.title = "Gateway Token"
                $0.placeholder = "12345"
                $0.tag = "gatewayTokenRow"
                $0.value = self.localGatewayToken
                }.cellSetup { cell, row in
                    cell.backgroundView?.backgroundColor = UIColor.gray
                }.onChange { row in
                    // Guard against empty field
                    guard let cid = row.value else {
                        row.value = ""
                        return
                    }
                    // If value present then set local
                    self.localGatewayToken = cid
            }
            
            +++ Section("Login Redirect URI")
            
            <<< TextRow(){ row in
                row.placeholder = "com.okta.joeb.oktapiamsample:/callback"
                row.tag = "redirectRow"
                row.value = localRedirect
                row.disabled = true
                }.cellSetup { cell, row in
                    cell.backgroundView?.backgroundColor = UIColor.gray
                }
        
        form
            +++ SelectableSection<ListCheckRow<String>>("Scopes (Multi-Selection Supported)", selectionType: .multipleSelection)
        
            let scopes = ["openid", "profile", "email", "address", "phone", "offline_access","https://oktacarrental.com/vehicles.read","https://oktacarrental.com/book"]
            for option in scopes {
                form.last! <<< ListCheckRow<String>(option){ listRow in
                    listRow.title = option
                    listRow.selectableValue = option
                    listRow.value = nil
                    listRow.tag = listRow.title
                    switch option {
                    case "openid":
                        listRow.title = "\(option)"
                        listRow.disabled = true
                    case "profile":
                        listRow.title = "\(option)"
                        listRow.disabled = true
                    case "https://oktacarrental.com/vehicles.read":
                        listRow.title = "\(option)"
                        listRow.disabled = true
                    default:
                        listRow.disabled = false
                    }
                    }.cellSetup { cell, row in
                        cell.backgroundView?.backgroundColor = UIColor.gray
                    }.onChange { row in
                        
                        switch option {
                            
                        case "openid":
                            
                            if row.value != nil {
                                
                                self.localOpenIdSwitch = true
                            } else {
                                
                                self.localOpenIdSwitch = false
                            }
                            
                        case "profile":
                            
                            if row.value != nil {
                                
                                self.localProfileSwitch = true
                            } else {
                                
                                self.localProfileSwitch = false
                            }
                            
                        case "email":
                            
                            if row.value != nil {
                                
                                self.localEmailSwitch = true
                            } else {
                                
                                self.localEmailSwitch = false
                            }
                            
                        case "address":
                            
                            if row.value != nil {
                                
                                self.localAddressSwitch = true
                            } else {
                                
                                self.localAddressSwitch = false
                            }
                            
                        case "phone":
                            
                            if row.value != nil {
                                
                                self.localPhoneSwitch = true
                            } else {
                                
                                self.localPhoneSwitch = false
                            }
                            
                        case "offline_access":
                            
                            if row.value != nil {
                                
                                self.localOfflineSwitch = true
                            } else {
                                
                                self.localOfflineSwitch = false
                            }
                        case "https://oktacarrental.com/vehicles.read":
                            
                            if row.value != nil {
                                
                                self.localVechiclesSwitch = true
                            } else {
                                
                                self.localVechiclesSwitch = false
                            }
                        case "https://oktacarrental.com/book":
                            
                            if row.value != nil {
                                
                                self.localBookSwitch = true
                            } else {
                                
                                self.localBookSwitch = false
                            }
                            
                        default:
                            print("Option de-selected was: " + option)
                        }
                }
        }
                
        form
            // Temporary setting to [.None] - Need to come up with logic to loop when a user removes custom scope.  This is do to the fact that the tag is being setting a load (Custom1).
            // Options [.Reorder, .Insert, .Delete]
            +++ MultivaluedSection(multivaluedOptions: [.None],
                                   
                                   header: "Custom Scopes") {
                                    $0.tag = "CustomScopesSection"
                                    $0.addButtonProvider = { section in
                                        return ButtonRow(){
                                            $0.title = "Add Custom Scope"
                                        }
                                    }
                                    $0.multivaluedRowToInsertAt = { index in
                                        return NameRow() {
                                            $0.placeholder = "Enter Custom Scope"
                                            $0.title = ("Custom" + String(index + 1))
                                            $0.tag = ("Custom" + String(index + 1))
                                        }
                                    }
                                    
                                    var whileCount = localCustomCount
                                    //var whileCount = localCustomScopes.count
                                    
                                    while whileCount >= 1 {
                                        
                                        $0 <<< NameRow() { row in
                                            row.title = "Custom\(localCustomCount - (whileCount - 1))"
                                            row.tag = "Custom\(localCustomCount - (whileCount - 1))"
                                        }
                                        whileCount -= 1
                                    }
                                    //}
        }
        
        form
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Close"
                }.cellSetup { cell, row in
                    cell.backgroundView?.backgroundColor = UIColor.gray
                }
                .onCellSelection { [weak self] (cell, row) in
                    self?.closeConfig()
                }
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Save & Close"
                }.cellSetup { cell, row in
                    cell.backgroundView?.backgroundColor = UIColor.gray
                }
                .onCellSelection { [weak self] (cell, row) in
                    self?.saveCloseConfig()
        }
        
        //Set Form Values from Locals
        form.setValues(self.localFormValues)
    }
    
    //  Close Configuration View Without Saving
    
    func closeConfig() {
        
        //self.performSegue(withIdentifier: "unwindToMainView", sender: self)
        self.performSegue(withIdentifier: "unwindToCarViewFromConfig", sender: self)
    }
    
    //  Save and Call Alert to Close Configuration View
    
    func saveCloseConfig(){
        
        SwiftyPlistManager.shared.save(localClientId, forKey: "clientId", toPlistWithName: "Okta") { (err) in
            if err == nil {
                print("\nClient ID successfully saved into Okta.plist.")
            } else {
                
                alertForSave(messageTxt: "Client ID failed to save.  Check you entry and try again.")
                return
            }
        }
        
        SwiftyPlistManager.shared.save(localIssuer, forKey: "issuer", toPlistWithName: "Okta") { (err) in
            if err == nil {
                print("Issuer successfully saved into Okta.plist.")
            } else {
                
                alertForSave(messageTxt: "Issuer failed to save.  Check you entry and try again.")
                return
            }
        }
        
        SwiftyPlistManager.shared.save(localGateway, forKey: "gateway", toPlistWithName: "Okta") { (err) in
            if err == nil {
                print("Gateway successfully saved into Okta.plist.")
            } else {
                
                alertForSave(messageTxt: "Gateway failed to save.  Check you entry and try again.")
                return
            }
        }
        
        SwiftyPlistManager.shared.save(localGatewayToken, forKey: "gatewayToken", toPlistWithName: "Okta") { (err) in
            if err == nil {
                print("Gateway Token successfully saved into Okta.plist.")
            } else {
                
                alertForSave(messageTxt: "Gateway Token failed to save.  Check you entry and try again.")
                return
            }
        }
        
        scopesToSave = ["openid": localOpenIdSwitch, "profile": localProfileSwitch, "email": localEmailSwitch, "address": localAddressSwitch, "phone": localPhoneSwitch, "offline_access": localOfflineSwitch, "https://oktacarrental.com/vehicles.read" : localVechiclesSwitch, "https://oktacarrental.com/book": localBookSwitch]
        
        for scopes in scopesToSave {
            
            if (scopes.value == true) {
                
                //print("To Save: " + scopes.key)
                
                localScopes.insert(scopes.key, at: 0)
            }
        }
        
        
        let section: Section?  = form.sectionBy(tag: "CustomScopesSection")

        //print("\n********** Total Form Entries \(section!.form!.allRows.count)")

        if section!.form!.allRows.count > 10 {

            //print("Custom Scope Present")
            var totalCustoms = section!.form!.allRows.count - 10
            //print("Total Customs \(totalCustoms)")

            while totalCustoms >= 1 {

                //$0.tag = ("Custom" + String(index + 1))
                //if row.value != nil {
                let customRow: NameRow? = form.rowBy(tag: "Custom\(totalCustoms)")

                let customValue = customRow?.value

                if customValue != nil {

                    localScopes.insert(customValue!, at: 0)
                }
                totalCustoms -= 1
            }

        } else {

            print("Custom Scope Not Present")
        }
        
        // Save Scopes back to Okta.plist
        SwiftyPlistManager.shared.save(localScopes, forKey: "scopes", toPlistWithName: "Okta") { (err) in
            if err == nil {
                print("Scopes successfully saved into Okta.plist.")
            } else {
                
                alertForSave(messageTxt: "Scopes failed to save.  Check you entry and try again.")
                return
            }
        }
        
        print("\n********** Okta Locals Saved **********")
        
        SwiftyPlistManager.shared.getValue(for: "issuer", fromPlistWithName: "Okta") { (result, err) in
            if err == nil {
                print("Issuer: '\(result ?? "No Value Fetched")'")
            }
        }
        
        SwiftyPlistManager.shared.getValue(for: "clientId", fromPlistWithName: "Okta") { (result, err) in
            if err == nil {
                print("Client Id: '\(result ?? "No Value Fetched")'")
            }
        }
        
        SwiftyPlistManager.shared.getValue(for: "gateway", fromPlistWithName: "Okta") { (result, err) in
            if err == nil {
                print("Gateway: '\(result ?? "No Value Fetched")'")
            }
        }
        
        SwiftyPlistManager.shared.getValue(for: "gatewayToken", fromPlistWithName: "Okta") { (result, err) in
            if err == nil {
                print("Gateway Token: '\(result ?? "No Value Fetched")'")
            }
        }
        
        SwiftyPlistManager.shared.getValue(for: "scopes", fromPlistWithName: "Okta") { (result, err) in
            if err == nil {
                print("OAuth Scopes: '\(result ?? "No Value Fetched")'")
            }
        }
        
        alertForSave(messageTxt: "Return to login screen to connect to Okta Org.")
    }
    
    // MARK: Helpers (Alerts, Header Class)
    
    func alertForSave(messageTxt: String) {
        
        let alert = UIAlertController(title: "Save Successful", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        alert.message = messageTxt
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            //self.performSegue(withIdentifier: "unwindToMainView", sender: self)
            self.performSegue(withIdentifier: "unwindToCarViewFromConfig", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            print("Cancel Alert")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

class EurekaLogoViewNib: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
