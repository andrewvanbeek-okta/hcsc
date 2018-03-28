//
//  CarViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/16/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

import UIKit
import OktaAuth
import SwiftyPlistManager
import PKHUD
import Alamofire
import JWTDecode
import SwiftyJSON
import HGPlaceholders
import AZDropdownMenu
import SafariServices

class CarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var carCollectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    
    var models: [CarCellModel] = []
    
    var carDetailModelController: CarDetailModelController!
    var carInventoryModelController: CarInventoryModelController!
    var carBookingModelController: CarBookingModelController!
    var userDetailModelController: UserDetailModelController!
    
    var bookFlag: Bool = false

    //var placeholderCollectionView: CollectionView?
    
    var menu: AZDropdownMenu?
    
    var placeholderCollectionView: CollectionView? {
        return carCollectionView as? CollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        setupMenu(loggedIn: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check booking model and reload car inventory collection view if found.

        if (carBookingModelController.bookResult.confNum) != "" {

            print("********** Booking Result Found - Reload Table to Show Booked Car **********")

            bookFlag = true
            carCollectionView.reloadData()
        } else if (bookFlag == true) {
            
            bookFlag = false
            carCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View Setup
    
    func setupView() {
        
        //print("\n********** Setup Car Inventory Collection View **********")
        
        // Create collection view placeholder and offset.
        
        placeholderCollectionView?.placeholdersProvider = .oktaNoData
        placeholderCollectionView?.placeholderDelegate = self
        placeholderCollectionView?.showLoadingPlaceholder()
        
        carCollectionView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
        carCollectionView.contentOffset = CGPoint(x: 0, y: 100)
        
    }
    
    func refreshView() {
        
        UIView.transition(with: self.carCollectionView,
                          duration: 1.0,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.placeholderCollectionView?.showLoadingPlaceholder()
        })
        
        let indexPath = IndexPath(item: 0, section: 0)
        self.carCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return self.models.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carInventoryCell", for: indexPath) as! CarCollectionViewCell
        cell.model = self.modelAtIndexPath(indexPath)
        
        if cell.model.carAvail == "true" {

            cell.availTitle.text = "Available"
        } else {

            cell.availTitle.text = "Sold Out"
        }

        if cell.model.carId == self.carBookingModelController.bookResult.carId {

            cell.bookedLabel.alpha = 1
            cell.bookedLabel.text = "Booked: (\(carBookingModelController.bookResult.confNum))"
        } else {

            cell.bookedLabel.alpha = 0
            cell.bookedLabel.text = ""
        }
        
        cell.layer.cornerRadius = 15
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 15).cgPath
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 1
        let availableWidth = collectionView.frame.width - 50
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem + (widthPerItem / 4))
    }
    
    func modelAtIndexPath(_ indexPath: IndexPath) -> CarCellModel {
        return self.models[(indexPath as NSIndexPath).row % self.models.count]
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let carCell = self.modelAtIndexPath(indexPath)
        
        let car4DetailPage = CarDetail(id: carCell.carId, make: carCell.carMake, model: carCell.carModel, carClass: carCell.carClass, avail: carCell.carAvail, desc: carCell.carDesc, price: carCell.carPrice, imgUrl: carCell.carImageUrl)
        carDetailModelController.carDetail = car4DetailPage
        
        if carBookingModelController.bookResult.carId == "" {
            
            let car4Booking = BookRequest(carId: carCell.carId, rentalDays: [], carPrice: Int(carCell.carPrice)!)
            carBookingModelController.bookRequest = car4Booking
        }
        
        print("Segue to Car Details")
        self.performSegue(withIdentifier: "carDetails", sender: self)
    }
    
    @objc private func refreshCarTableData(_ sender: Any) {
        
        guard let fetchedAcToken = (OktaAuth.tokens?.get(forKey: "accessToken")) else {
            
            generalAlert(titleTxt: "Access Token Not Present!", messageTxt: "Please Login.")
            return
        }
        
        // Call for inventory with Okta Access Token
        
        self.getInventory(accessToken: fetchedAcToken)
    }
    
    // Mark: Okta functions
    
    @IBAction func oktaLogin(_ sender: Any) {
        
        //  Get Okta information to check configuration
        
        guard let fetchedIssuer = SwiftyPlistManager.shared.fetchValue(for: "issuer", fromPlistWithName: "Okta"), isSettingValid(value: fetchedIssuer as! String) else {
            
            print("Issuer Required!")
            generalAlert(titleTxt: "Issuer Required!", messageTxt: "Update settings and retry login.")
            return
        }
        
        guard let fetchedClientId = SwiftyPlistManager.shared.fetchValue(for: "clientId", fromPlistWithName: "Okta"), isSettingValid(value: fetchedClientId as! String) else {
            
            print("Client ID Required!")
            generalAlert(titleTxt: "Client ID Required!", messageTxt: "Update settings and retry login.")
            return
        }
        
        let fetchedScopes = SwiftyPlistManager.shared.fetchValue(for: "scopes", fromPlistWithName: "Okta") as! Array<Any>
        
        if fetchedScopes.count == 0 {
            
            print("Scopes Required!")
            generalAlert(titleTxt: "Scopes Required!", messageTxt: "Update settings and retry login.")
            return
        }
        
        let query = "profile"
        var found = false
        
        for scope in fetchedScopes {
            
            if scope as! String == query {
                
                found = true
            }
        }
        
        if found != true {
            
            print("Profile Scope Required!")
            generalAlert(titleTxt: "Profile Scope Required!", messageTxt: "Update settings and retry login.")
        }
        
        // Call Okta to initiate login flow.  (Currently using the Client Creds - PKCE OAuth Flow)
        
        clearPrevTokens()
        callOktaOrg()
    }
    
    func clearPrevTokens() {
        
        OktaAuth.tokens?.clear()
    }
    
    func revokeTokens() {
        
        guard let idToken = (OktaAuth.tokens?.get(forKey: "idToken")) else {
            
            generalAlert(titleTxt: "Id Token Not Present!", messageTxt: "Please Login.")
            return
        }
        
        OktaAuth.revoke(idToken) { response, error in
            
            if error != nil { print("Error: \(error!)") }
            if response != nil { print("Id Token was Revoked") }
        }
        
        guard let acToken = (OktaAuth.tokens?.get(forKey: "accessToken")) else {
            
            generalAlert(titleTxt: "Id Token Not Present!", messageTxt: "Please Login.")
            return
        }
        
        OktaAuth.revoke(acToken) { response, error in
            
            if error != nil { print("Error: \(error!)") }
            if response != nil { print("Access Token was Revoked") }
        }
        
        
    }
    
    func callOktaOrg() {
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        OktaAuth
            .login()
            .start(self) { response, error in
                
                if error != nil { self.generalAlert(titleTxt: "Login Error", messageTxt:  error.debugDescription.description)}
                
                // Success
                if let tokenResponse = response {
                    
                    self.models = []
                
                    
                    var tokenString = ""
                    
                    if let idToken = tokenResponse.idToken {
                        tokenString += "\nID Token Token: \(idToken)\n"
                        
                        OktaAuth.tokens?.set(
                            value: tokenResponse.idToken!,
                            forKey: "idToken"
                        )
                    }
                    
                    if let accessToken = tokenResponse.accessToken {
                        tokenString += ("\nAccess Token: \(accessToken)\n")
                        
                        OktaAuth.tokens?.set(
                            value: tokenResponse.accessToken!,
                            forKey: "accessToken"
                        )
                        
                        // Call for Inventory
                        
                        self.getInventory(accessToken: accessToken)
                        
                    }
                    
                    if let refreshToken = tokenResponse.refreshToken {
                        tokenString += "\nRefresh Token: \(refreshToken)\n"
                        
                        OktaAuth.tokens?.set(
                            value: tokenResponse.refreshToken!,
                            forKey: "refreshToken"
                        )
                        
                    }
                    
                    if let codeVerifier = tokenResponse.authState?.lastTokenResponse?.request.codeVerifier {
                        
                        tokenString += "\nCode Verifier: \(codeVerifier)\n"
                    }
                    
                    print("\n********** Okta Response Tokens **********")
                    print(tokenString)
                    
                    HUD.flash(.success, delay: 1.0)
                    
                    self.populateUserDetailModel()
                    
                    self.setupMenu(loggedIn: true)
                    
                } else {
                    
                    HUD.flash(.error, delay: 0.1)
                }
        }
    }
    
    //  Make: Get Inventory From Apigee
    
    func getInventory(accessToken: String) {
        
        guard let fetchedGateway = SwiftyPlistManager.shared.fetchValue(for: "gateway", fromPlistWithName: "Okta") else {
            
            print("Gateway Required for Inventery Call.")
            generalAlert(titleTxt: "Gateway Required!", messageTxt: "Update settings and retry inventory request.")
            return
        }
        
        let authNUrl = "\(fetchedGateway)/oktacarrental/v1/vehicles"
        
        //print(authNUrl)
        
        let headers = ["Authorization": "Bearer " + accessToken]
        
        Alamofire.request(authNUrl,
                          method: .get,
                          headers: headers).responseJSON { response in
                            
                            switch response.result {
                            case .success(_):
                            
                                let jsonInventory = JSON(response.result.value as Any)
                                
                                let newCarInventory = CarInventory(inventory: jsonInventory)
                                self.carInventoryModelController.carInventory = newCarInventory
                                
                                let cars = jsonInventory["inventory"].arrayValue
                                
                                // Clear Model to Prepare for New Inventory
                                
                                self.models.removeAll()
                                
                                for car in cars {
                                    
                                    //  Might need to move this line outside for loop
                                    let carUser = self.userDetailModelController.userDetail
                                    
                                    if car["class"].stringValue == carUser.userCarPref {
                                        
                                        self.models.insert(CarCellModel(id: car["id"].stringValue, make: car["make"].stringValue, model: car["model"].stringValue, price: car["price"].stringValue, image: car["image_url"].stringValue, carClass: car["class"].stringValue, avail: car["avail"].stringValue, desc: car["desc"].stringValue), at: 0)
                                    } else {
                                        
                                        self.models.append(CarCellModel(id: car["id"].stringValue, make: car["make"].stringValue, model: car["model"].stringValue, price: car["price"].stringValue, image: car["image_url"].stringValue, carClass: car["class"].stringValue, avail: car["avail"].stringValue, desc: car["desc"].stringValue))
                                    }
                                    
                                    
                                }
                                
                                self.refreshControl.endRefreshing()
                                
                                UIView.transition(with: self.carCollectionView,
                                                  duration: 1.5,
                                                  options: .transitionCrossDissolve,
                                                  animations: {
                                                        self.carCollectionView.reloadData()
                                                    })
                                
                                self.carCollectionView.addSubview(self.refreshControl)
                                self.refreshControl.addTarget(self, action: #selector(self.refreshCarTableData(_:)), for: .valueChanged)
                                
                                let indexPath = IndexPath(item: 0, section: 0)
                                self.carCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                                
                            case .failure(let error):
                                
                                self.refreshControl.endRefreshing()
                                self.generalAlert(titleTxt: "Inventory Error.", messageTxt: "\(error.localizedDescription)")
                            }
        }
    }
    
    func populateUserDetailModel () {
        
        // Check for ID Token
        
        guard let fetchedIdToken = (OktaAuth.tokens?.get(forKey: "idToken")) else {

            generalAlert(titleTxt: "ID Token Not Present!", messageTxt: "Please Login.")
            return
        }
        
        // Decode ID Token
        
        let decodedIdToken = self.decodeTokens(token: fetchedIdToken)
        
        // Check for oktaCarMembership as a claim.
        
        let localCarMem = self.isClaimFoundAndNotNil(token: decodedIdToken, claim: "oktaCarMembership")
        
        // Check for oktaCarPreference as a claim.
        
        let localCarPref = self.isClaimFoundAndNotNil(token: decodedIdToken, claim: "oktaCarPreference")
        
        // Define a carUser using decoded values from ID Token.
        
        let carUser = UserDetail(userName: decodedIdToken["name"] as! String, userPrefName: decodedIdToken["preferred_username"] as! String, userMemLvl: localCarMem, userCarPref: localCarPref, userGrps: [])
        
        // Set userDetail Model using carUser.
        
        userDetailModelController.userDetail = carUser
    }
    
    // MARK: Log out
    
    func logoutPressed() {
        
        guard let idToken = (OktaAuth.tokens?.get(forKey: "idToken")) else {
            
            generalAlert(titleTxt: "Id Token Not Present!", messageTxt: "Please Login.")
            return
        }
        
        let decodedIdToken = self.decodeTokens(token: idToken)
        let userOktaId = decodedIdToken["sub"]
        
        clearUserSession(user: userOktaId as! String)
        
        let emptyCarUser = UserDetail(userName: "", userPrefName: "", userMemLvl: "" , userCarPref: "" , userGrps: [])
        userDetailModelController.userDetail = emptyCarUser
    }
    
    func clearUserSession (user: String) {
        
        guard let fetchedGateway = SwiftyPlistManager.shared.fetchValue(for: "gateway", fromPlistWithName: "Okta") else {
            
            print("Gateway Required for Inventery Call.")
            generalAlert(titleTxt: "Gateway Required!", messageTxt: "Update settings and retry inventory request.")
            return
        }
        
        let authNUrl = "\(fetchedGateway)/oktacarrental/v1/clearusersession"
        
        //print(authNUrl)
        
        guard let fetchedGatewayToken = SwiftyPlistManager.shared.fetchValue(for: "gatewayToken", fromPlistWithName: "Okta") else {
            
            print("Gateway Token Required for Inventery Call.")
            generalAlert(titleTxt: "Gateway Token Required!", messageTxt: "Update settings and retry request.")
            return
        }
        
        let headers = ["Authorization": "Bearer \(fetchedGatewayToken)"]
        
        let userSessionReq = [
            
            "userId": "\(user)"
            ] as [String : Any]
        
        Alamofire.request(authNUrl, method: .delete,
                          parameters: userSessionReq,
                          encoding: JSONEncoding.default,
                          headers: headers).responseJSON { (response:DataResponse<Any>) in
                            
                            print("Request: \(String(describing: response.request))")
                            print("Result: \(response.result)")
                            
                            switch response.result {

                            case .success:
                                
                                self.revokeTokens()
                                self.clearPrevTokens()
                                
                                self.models = []
                                
                                let emptyCarInventory = CarInventory(inventory: JSON.null)
                                self.carInventoryModelController.carInventory = emptyCarInventory
                                
                                let emptyBookRequest = BookRequest(carId: "", rentalDays: [], carPrice: 0)
                                let emptyBookResult = BookResult(carId: "", estPrice: "", confNum: "")
                                self.carBookingModelController.bookRequest = emptyBookRequest
                                self.carBookingModelController.bookResult = emptyBookResult
                                
                                self.setupMenu(loggedIn: false)
                                
                                self.refreshView()
                                
                            case .failure(let error):

                                print("Result: \(error.localizedDescription)")
                            }
                            
                            
        }
    }
    
    // MARK: Menu
    
    func setupMenu(loggedIn: Bool) {
        
        let userState = loggedIn
        let dataSource = createMenuDataSource(loggedIn: userState)
        self.menu = AZDropdownMenu(dataSource: dataSource)
        menu?.cellTapHandler = { [weak self] (indexPath: IndexPath) -> Void in
            self?.azMenuItemPressed(dataSource[indexPath.row])
        }
        
        self.menu?.itemHeight = 44
        self.menu?.itemFontSize = 14.0
        self.menu?.itemFontName = "Avenir-Light"
        self.menu?.itemColor = UIColor.white
        self.menu?.itemSelectionColor = UIColor.clear
        self.menu?.itemFontColor = UIColor(red: 55/255, green: 11/255, blue: 17/255, alpha: 1.0)
        self.menu?.overlayColor = UIColor.black
        self.menu?.overlayAlpha = 0.50
        self.menu?.itemAlignment = .left
        self.menu?.itemImagePosition = .prefix
        self.menu?.menuSeparatorStyle = .singleline
        self.menu?.shouldDismissMenuOnDrag = true
    }
    
    fileprivate func createMenuDataSource(loggedIn: Bool) -> [AZDropdownMenuItemData] {
        
        if loggedIn == true {
            
            var dataSource: [AZDropdownMenuItemData] = []
            
            dataSource.append(AZDropdownMenuItemData(title: "Okta Car Rental Platform"))
            //dataSource.append(AZDropdownMenuItemData(title:"Welcome, \(self.userDetailModelController.userDetail.userName) (\(self.userDetailModelController.userDetail.userMemLvl))"))
            //dataSource.append(AZDropdownMenuItemData(title:"Preference \(self.userDetailModelController.userDetail.userCarPref)"))
            dataSource.append(AZDropdownMenuItemData(title:"Profile", icon:UIImage(imageLiteralResourceName: "profileIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"Inspector", icon:UIImage(imageLiteralResourceName: "inspIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"App Config", icon:UIImage(imageLiteralResourceName: "configIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"About", icon:UIImage(imageLiteralResourceName: "aboutIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"Logout", icon:UIImage(imageLiteralResourceName: "logoutIcon")))
            
            return dataSource
        } else {
            
            var dataSource: [AZDropdownMenuItemData] = []
            
            dataSource.append(AZDropdownMenuItemData(title: "Okta Car Rental Demo"))
            dataSource.append(AZDropdownMenuItemData(title:"Login", icon:UIImage(imageLiteralResourceName: "loginIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"Registration", icon:UIImage(imageLiteralResourceName: "regIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"App Config", icon:UIImage(imageLiteralResourceName: "configIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"About", icon:UIImage(imageLiteralResourceName: "aboutIcon")))
            dataSource.append(AZDropdownMenuItemData(title:"Development", icon:UIImage(imageLiteralResourceName: "devIcon")))
            
            return dataSource
        }
        
    }
    
    // Menu Option Pressed
    
    func azMenuItemPressed(_ item: AZDropdownMenuItemData) {
        
        print(item.title)
        
        switch item.title {
        case "Login":
            oktaLogin(self)
        case "App Config":
            self.performSegue(withIdentifier: "config", sender: self)
        case "Inspector":
            self.performSegue(withIdentifier: "inspect", sender: self)
        case "Profile":
            self.performSegue(withIdentifier: "user", sender: self)
        case "Registration":
            self.performSegue(withIdentifier: "register", sender: self)
        case "About":
            self.performSegue(withIdentifier: "about", sender: self)
        case "Development":
            openDevSite(self)
        case "Logout":
            logoutPressed()
        default:
            print("Menu selection didn't trigger action.")
        }
    }
    
    // Open Menu
    
    @IBAction func menuPressed(_ sender: Any) {
        
        if (self.menu?.isDescendant(of: self.view) == true) {
            self.menu?.hideMenu()
        } else {
            
            self.menu?.showMenuFromView(self.view)
        }
    }
    
    // Open Developer Site
    
    func openDevSite(_ sender: Any) {
        
        let devUrl = "https://developer.okta.com"
        let svc = SFSafariViewController(url: NSURL(string: devUrl)! as URL)
        
        self.present(svc, animated: true, completion: nil)
    }
    
    // MARK: Helpers (Alerts, Decoders, Segues)
    
    func generalAlert(titleTxt: String, messageTxt: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        alert.title = titleTxt
        alert.message = messageTxt
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func decodeTokens (token :String) -> Dictionary<String, Any>{
        
        do {
            let jwt = try decode(jwt: token)
            let jwtBody = jwt.body
            
            //print(jwtBody)
            
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
    
    func isSettingValid(value: String) -> Bool {
        
        if value == "Required" || value == "" {
            
            return false
        }
        
        return true
    }
    
    func isClaimFoundAndNotNil(token: Dictionary<String, Any>, claim: String) -> String {
        
        // Check for Claim
        
        if let localClaim = token[claim] {
            
            print ("Custom Claim Found: \(claim)")
            
            // Check for value
            
            if (localClaim as! String).count != 0 {
                
                print ("Custom Claim Value Found: \(localClaim as! String)")
                
                return String(describing: localClaim)
            }
        }
        
        // If Claim not present or nil return emtpy string for model
        
        print ("Custom Claim Missing or Null: \(claim)")
        
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let carDetailViewController = segue.destination as? CarDetailViewController {
            carDetailViewController.carDetailModelController = carDetailModelController
            carDetailViewController.carBookingModelController = carBookingModelController
            carDetailViewController.userDetailModelController = userDetailModelController
        }
        
        if let userProfileViewController = segue.destination as? UserProfileViewController {
            
            userProfileViewController.carInventoryModelController = carInventoryModelController
            userProfileViewController.userDetailModelController = userDetailModelController
            userProfileViewController.carBookingModelController = carBookingModelController
        }
    }
    
     @IBAction func unwindToCar(segue: UIStoryboardSegue) {print("At Car")}
    
}

// MARK: Placeholder Delegates and Datasource

extension CarViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
       
        print(placeholder.key.value)
        oktaLogin(self)
    }
    
}

