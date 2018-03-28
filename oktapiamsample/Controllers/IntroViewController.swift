//
//  IntroViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 12/5/17.
//  Copyright © 2017 Joe Burgett. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    
    @IBOutlet weak var introButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        introButton.alpha = 1.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Helpers (Segues)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Intialize Models and Pass to CarViewController
        
        if let carViewController = segue.destination as? CarViewController {
            
            carViewController.carDetailModelController = CarDetailModelController()
            carViewController.carInventoryModelController = CarInventoryModelController()
            carViewController.carBookingModelController = CarBookingModelController()
            carViewController.userDetailModelController = UserDetailModelController()
        }
    }
}
