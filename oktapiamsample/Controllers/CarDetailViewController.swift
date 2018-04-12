//
//  CarDetailViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/18/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import PKHUD
import SwiftyJSON
import OktaAuth
import SwiftyPlistManager

class CarDetailViewController: UIViewController {
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var availLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var bookedLabel: UILabel!
    @IBOutlet weak var confLabel: UILabel!
    
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var carDetailModelController: CarDetailModelController!
    var carBookingModelController: CarBookingModelController!
    var userDetailModelController: UserDetailModelController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - View Setup
    
    func setupView (){
        
        let carDetails = carDetailModelController.carDetail
        let carBooking = carBookingModelController.bookResult
        print("\n********** Car Details Debug **********")
        print("\(carDetails.make) \(carDetails.model) Displayed")
        
        // Testing Kingfisher Image Helper
        let placeImg = UIImage(named: "oktaWhite")
        let url = URL(string: carDetails.imgUrl)!
        carImage.kf.setImage(with: url, placeholder: placeImg)
        
        if carBooking.carId != "" && carBooking.carId == carDetails.id { // Detail Car is same as Booked Car
            
            bookButton.alpha = 0
            calendarButton.alpha = 0
            bookedLabel.alpha = 1
            confLabel.alpha = 1
            confLabel.text = carBookingModelController.bookResult.confNum
            cancelButton.alpha = 1
        } else if carBooking.carId != "" && carBooking.carId != carDetails.id { // Detail Car isn't same as Booked Car
            
            bookButton.alpha = 0
            calendarButton.alpha = 0
            bookedLabel.alpha = 0
            confLabel.alpha = 0
            cancelButton.alpha = 0
        } else { // No Car Booked
            
            bookButton.alpha = 1
            calendarButton.alpha = 1
            bookedLabel.alpha = 0
            confLabel.alpha = 0
            cancelButton.alpha = 0
        }
        
        makeLabel.text = carDetails.make
        modelLabel.text = carDetails.model
        priceLabel.text = "$\(carDetails.price) /visit"
        
        if carDetails.avail == "true" {
            
            availLabel.text = "Available"
        } else {
            
            availLabel.text = "Sold out"
        }
        classLabel.text = "Class: \(carDetails.carClass)"
        descLabel.text = carDetails.desc
    }

    //  Book Car From Apigee
    
    @IBAction func bookRental() {
        
        let carDetails = carDetailModelController.carDetail
        let carBooking = carBookingModelController.bookRequest
        let userDetails = userDetailModelController.userDetail
        
        if carDetails.carClass == "Premium" {
            
            if userDetails.userMemLvl != "Platinum" {
                
                generalAlert(titleTxt: "Membership Level", messageTxt: "Premium cars are only available to Platinum members.")
                return
            }
        }
        
        if carDetails.avail == "false" {
            
            generalAlert(titleTxt: "Car Sold Out", messageTxt: "Sorry!")
            return
        }
        
        if carBooking.rentalDays.count == 0 {
            
            generalAlert(titleTxt: "Rental Days Needed.", messageTxt: "Select rental days using the calendar.")
            return
        }
        
        guard let fetchedGateway = SwiftyPlistManager.shared.fetchValue(for: "gateway", fromPlistWithName: "Okta") else {
            
            print("Gateway Required for Inventery Call.")
            generalAlert(titleTxt: "Gateway Required!", messageTxt: "Update settings and retry inventory request.")
            return
        }
        
        let authNUrl = "\(fetchedGateway)/oktacarrental/v1/book"
        
        //let authNUrl = "https://joeburgett-eval-test.apigee.net/oktacarrental/v1/book"
        
        print(authNUrl)
        
        let headers = ["Authorization": "Bearer " + (OktaAuth.tokens?.get(forKey: "accessToken"))!]
        
        let carRentalReq = [
            
            "vehicle_id": carDetails.id,
            "days": carBooking.rentalDays.count,
            "price": carDetails.price
            ] as [String : Any]
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        Alamofire.request(authNUrl, method: .post, parameters: carRentalReq, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                HUD.flash(.success, delay: 1.0)
                
                let jsonBooking = JSON(response.result.value as Any)
                
                if let confirmationCode = jsonBooking["confirmation_code"].string {
                    
                    self.confLabel.text = confirmationCode
                    
                    UIView.transition(with: self.view,
                                      duration: 1.0,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                        
                                        self.bookButton.alpha = 0
                                        self.calendarButton.alpha = 0
                                        self.bookedLabel.alpha = 1
                                        self.confLabel.alpha = 1
                                        self.cancelButton.alpha = 1
                    })
                    
                    let carBooked = BookResult(carId: jsonBooking["vehicle_id"].stringValue, estPrice: jsonBooking["estimated_cost"].stringValue, confNum: jsonBooking["confirmation_code"].stringValue)
                    self.carBookingModelController.bookResult = carBooked
                }
                
                if let errorMessage = jsonBooking["Error"].string {
                    
                    HUD.flash(.error, delay: 0.1)
                    self.generalAlert(titleTxt: "Booking Error.", messageTxt: "\(errorMessage)")
                }
                
            case .failure(let error):
                
                HUD.flash(.error, delay: 0.1)
                self.generalAlert(titleTxt: "Booking Error.", messageTxt: "\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Cancel Booking (Clear Booking Model)
    
    
    @IBAction func clearBooking(_ sender: Any) {
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        Timer.after(1.second) {
            
            HUD.flash(.success, delay: 1.0)
            
            UIView.transition(with: self.view,
                              duration: 1.5,
                              options: .transitionCrossDissolve,
                              animations: {
                                
                                self.bookButton.alpha = 1
                                self.calendarButton.alpha = 1
                                self.bookedLabel.alpha = 0
                                self.confLabel.text = ""
                                self.confLabel.alpha = 0
                                self.cancelButton.alpha = 0
            })
        }
        
        let emptyBookRequest = BookRequest(carId: "", rentalDays: [], carPrice: 0)
        let emptyBookResult = BookResult(carId: "", estPrice: "", confNum: "")
        self.carBookingModelController.bookRequest = emptyBookRequest
        self.carBookingModelController.bookResult = emptyBookResult
    }
    
    // MARK: Helpers (Alerts, Segues)
    
    func generalAlert(titleTxt: String, messageTxt: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        alert.title = titleTxt
        alert.message = messageTxt.description
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let calendarViewController = segue.destination as? CalendarViewController {
            
            calendarViewController.carBookingModelController = carBookingModelController
        }
        
        if let carViewController = segue.destination as? CarViewController {
            
            carViewController.carBookingModelController = carBookingModelController
        }
    }
    
    @IBAction func unwindToCarDetails(segue: UIStoryboardSegue) {print("At Car Details View")}
    
    @IBAction func backButtonPress(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToOktaCarViewFromDetails", sender: self)
    }
}
