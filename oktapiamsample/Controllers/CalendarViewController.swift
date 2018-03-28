//
//  CalendarViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/24/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var estPrice: UILabel!
    
    var rentalDays : Array <Date> = []
    
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var carBookingModelController: CarBookingModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Update calendar with current dates
        
        // Configure Calendar Experience
        
        calendarView.allowsMultipleSelection = true
        calendarView.swipeToChooseGesture.isEnabled = true
        
        let carBooking = carBookingModelController.bookRequest
        let currentRentalDates = carBooking.rentalDays
        
        print("********** Car Rental Dates Debug **********")
        print("Current Rental Dates: \(currentRentalDates)")
        
        currentRentalDates.forEach { (date) in
            self.calendarView.select(date as? Date, scrollToDate: false)
        }
        
        // Update labels with current day and est. price counts
        
        self.daysLabel.text = String(currentRentalDates.count)
        self.estPrice.text = String(self.calEstPrice(days: currentRentalDates.count, price: self.carBookingModelController.bookRequest.carPrice))
        
        // Update local rentalDays Array with previous selections
        
        rentalDays = currentRentalDates as! Array<Date>
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Calendar Delegates
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        
        let today = Date()
        
        if formatter.string(from: date) >= formatter.string(from: today) {
            
            rentalDays.append(date)
            
            print(rentalDays)
            print(rentalDays.count)
            
            UIView.animate(withDuration: 1.25, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: [], animations: {
                
                self.daysLabel.alpha = 0
                self.daysLabel.text = String(self.rentalDays.count)
                self.daysLabel.alpha = 1
                
                self.estPrice.alpha = 0
                self.estPrice.text = String(self.calEstPrice(days: self.rentalDays.count, price: self.carBookingModelController.bookRequest.carPrice))
                self.estPrice.alpha = 1
                
                
            }, completion: { _ in
                
                // Nothing needed at this time
            })
            
            return monthPosition == .current
            
        } else {
            
            return false
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        rentalDays = rentalDays.filter { $0 != date }

        print(rentalDays)
        print(rentalDays.count)
        
        UIView.animate(withDuration: 1.25, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.daysLabel.alpha = 0
            self.daysLabel.text = String(self.rentalDays.count)
            self.daysLabel.alpha = 1
            
            self.estPrice.alpha = 0
            self.estPrice.text = String(self.calEstPrice(days: self.rentalDays.count, price: self.carBookingModelController.bookRequest.carPrice))
            self.estPrice.alpha = 1
            
        }, completion: { _ in
            
            
        })
        
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
         print("did select date \(self.formatter.string(from: date))")
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    // MARK: Helpers (Alerts, Calculations, Segues)
    
    func calEstPrice(days: Int, price: Int) -> Int {
        
        let estPrice = days * price
        
        return estPrice
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let car4Booking = BookRequest(carId: carBookingModelController.bookRequest.carId, rentalDays: rentalDays, carPrice: carBookingModelController.bookRequest.carPrice)
        carBookingModelController.bookRequest = car4Booking
        
        if let carDetailViewController = segue.destination as? CarDetailViewController {
            
            carDetailViewController.carBookingModelController = carBookingModelController
        }
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToOktaCarDetailsViewFromCalendar", sender: self)
    }
}
