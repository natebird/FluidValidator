//
//  ViewController.swift
//  ExampleApp
//
//  Created by Antonio Di Giacomo on 26/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import FluidValidator

class ViewController: UIViewController {

    fileprivate var validator:RegistrationValidator = RegistrationValidator()
    fileprivate var registration:UserRegistration = UserRegistration()

    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func savePressed(_ sender: AnyObject) {
        self.registration.firstname = self.firstname.text
        self.registration.lastname = self.lastname.text
        self.registration.email = self.email.text
        
        let _ = self.validator.validate(object: self.registration)
        
        let error = validator.allErrors
        let alert = UIAlertController()
        let actionOk = UIAlertAction(title: "ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.title = "info"
        alert.addAction(actionOk)
        
        if error.failingFields().count > 0 {
            let errMessages = error.failingFields().map({ (fieldname) -> String in
                error.failMessageForPath(fieldname)!.errors.first!.extended
            }).joined(separator: "\n")
            alert.message = errMessages
        }else{
            alert.message = "Congrats! Validation passed!"
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

