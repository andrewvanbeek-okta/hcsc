//
//  AboutViewController.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 2/2/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!
    
    let messages =  ["Native App Example Powered by Okta API Access Management.",
                     "Okta adds authentication, authorization, and user management to your web or mobile app within minutes.",
                     "In This Example \n Okta Authorization Server grants 2 custom scopes for calls to the API gateway.",
                     "Gateway \n Car Rental APIs are hosted on an Apigee API Gateway.",
                     "Apigee API Gateway validates Okta access token locally and via the /introspect endpoint."
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        aboutLabel.alpha = 0.0
        
        setBuildLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.aboutMessages(index: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: About message animation and display
    
    func aboutMessages (index: Int) {
        
        var localInd = index
        let message = self.messages[index]
        self.aboutLabel.text = message
        
        self.aboutLabel.center.y += 30.0
        
        UIView.animateKeyframes(withDuration: 8.0, delay: 0.0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.10, animations: {
                
                self.aboutLabel.alpha = 0.8
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.10, relativeDuration: 0.05, animations: {
                
                self.animateMessageUp()
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.05, animations: {
                
                self.aboutLabel.alpha = 0.0
            })
            
            
        }, completion: { _ in
            
            if localInd == self.messages.count-1 {
                
                localInd = 0
            } else {
                
                localInd += 1
            }
            
            self.aboutMessages(index: localInd)
        })
    }
    
    func animateMessageUp() {
        
        UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.aboutLabel.center.y -= 30.0
            
            
        }, completion: nil)
    }
    
    // MARK: Set Build Label
    
    func setBuildLabel() {
        
        let version : AnyObject! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as AnyObject
        let build : AnyObject! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as AnyObject
        
        buildLabel.text = "Version \(version as! String) / Build \(build as! String)"
    }
    
    // MARK: Helpers (Segues)
    
    @IBAction func backButtonPress(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToCarViewFromAbout", sender: self)
    }

}
