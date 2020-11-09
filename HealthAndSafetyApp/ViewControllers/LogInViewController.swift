//
//  LogInViewController.swift
//  HeathAndSafetyApp
//
//  Created by Konstantin Georgiev on 29/03/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func ValidateFields() -> String? {
         
         if
         emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
         passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
         {
         
             return "Please fill in all fields."
         }
             
         return nil
         
    }
    func presentAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
       
    }

    @IBAction func logInClicked(_ sender: Any) {
        
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                let localizedDescription = error?.localizedDescription
                self.presentAlert(title:"Loging unsucessfull", message: localizedDescription!)
                self.errorLabel.text = error!.localizedDescription
            }
            else {
                
                
                let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as?
                HomeViewController
                
                
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
     
    }
    
}
