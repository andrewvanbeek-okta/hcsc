//
//  UserProfileViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/29/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD
import SwiftyTimer

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var prefLabel: UILabel!
    
    @IBOutlet weak var currentBookingLabel: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var estLabel: UILabel!
    @IBOutlet weak var confLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var models: [CarCellModel] = []
    
    var carInventoryModelController: CarInventoryModelController!
    var userDetailModelController: UserDetailModelController!
    var carBookingModelController: CarBookingModelController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK:- Populate View with User Information from Model
    
    func setupView() {
        
        // User Information
        
        userNameLabel.text = self.userDetailModelController.userDetail.userName
        memberLabel.text = "Level: \(self.userDetailModelController.userDetail.userMemLvl)"
        prefLabel.text = "Vehicle Pref: \(self.userDetailModelController.userDetail.userCarPref)"
        
        // Get Booked Car Data
        loadBookedCarFromInventory()
        
        // Booking Information
        
        self.currentBookingLabel.alpha = 0
        self.carImage.alpha = 0
        self.carLabel.alpha = 0
        self.estLabel.alpha = 0
        self.confLabel.alpha = 0
        self.cancelButton.alpha = 0
        
        if self.models.count != 0 {
            
            let placeImg = UIImage(named: "oktaWhite")
            let url = URL(string: self.models[0].carImageUrl)!
            self.carImage.kf.setImage(with: url, placeholder: placeImg)
            
            self.currentBookingLabel.alpha = 1
            self.carImage.alpha = 1
            
            self.carLabel.alpha = 1
            self.carLabel.text = "\(self.models[0].carMake) \(self.models[0].carModel)"
            self.estLabel.alpha = 1
            self.estLabel.text = "Est. Cost: $\(self.carBookingModelController.bookResult.estPrice) /total"
            self.confLabel.alpha = 1
            self.confLabel.text = "Conf. Code: \(self.carBookingModelController.bookResult.confNum)"
            
            self.cancelButton.alpha = 1
        }
    }
    
     // MARK:- Use Booking Model to populate View with current Booking

    func loadBookedCarFromInventory () {
        
        let carInventory = self.carInventoryModelController.carInventory
        
        let cars = carInventory.inventory["inventory"].arrayValue
        
        for car in cars {

            if car["id"].stringValue == self.carBookingModelController.bookResult.carId {

                self.models.insert(CarCellModel(id: car["id"].stringValue, make: car["make"].stringValue, model: car["model"].stringValue, price: car["price"].stringValue, image: car["image_url"].stringValue, carClass: car["class"].stringValue, avail: car["avail"].stringValue, desc: car["desc"].stringValue), at: 0)
            }


        }
    }
    
     // MARK:- Clear local Booking Model of current Booked Vehicle (Nothing to do at the server.  Bookings are only maintained at the client level)
    
    @IBAction func clearBooking(_ sender: Any) {
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        Timer.after(1.second) {
            
            HUD.flash(.success, delay: 1.0)
            
            UIView.transition(with: self.view,
                              duration: 1.5,
                              options: .transitionCrossDissolve,
                              animations: {
                                
                                self.currentBookingLabel.alpha = 0
                                self.carImage.alpha = 0
                                self.carLabel.alpha = 0
                                self.estLabel.alpha = 0
                                self.confLabel.alpha = 0
                                self.cancelButton.alpha = 0
            })
        }
        
        let emptyBookRequest = BookRequest(carId: "", rentalDays: [], carPrice: 0)
        let emptyBookResult = BookResult(carId: "", estPrice: "", confNum: "")
        self.carBookingModelController.bookRequest = emptyBookRequest
        self.carBookingModelController.bookResult = emptyBookResult
        
        
    }
    
    // MARK: Helpers (Segues)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let carViewController = segue.destination as? CarViewController {
            
            // Not sure if this is needed.  Might not be changing any user information.
            
            carViewController.userDetailModelController = userDetailModelController
            carViewController.carBookingModelController = carBookingModelController
        }
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToCarViewFromUser", sender: self)
    }
}
