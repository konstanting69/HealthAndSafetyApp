//
//  SignUpViewController.swift
//  HeathAndSafetyApp
//
//  Created by Konstantin Georgiev on 29/03/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import IQKeyboardManager


class SignUpViewController: UIViewController {
    
    var window: UIWindow?

      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().enableDebugging = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true

        return true
      }

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
        
        //Validation
        func ValidateFields() -> String? {
            
            if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)  == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            {
            
                return "Please fill in all fields."
            }
            
            let checkedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if Utilities.isPasswordValid(checkedPassword) == false {
                return "Please make sure your password is at least 8 characters, contains special character and a number"
            }
            
            return nil
        }
    func presentAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
       
    }
    
        
    func showError(message: String) {
            errorLabel.text = message
        print(message)
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        let error = ValidateFields()
        if error != nil {
            self.presentAlert(title: "Sign up unsuccessful", message: error!)
           
           
        }
        else{
            
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password =  passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password)
            { user, error in
                
                    if error != nil{
                        self.presentAlert(title:"Sign up unsuccessful", message: "Isncorectly formated email")
                    }
                
                    else {
                        
                        guard let uid = user?.user.uid else {
                            return
                        }
                        
                       
                        self.ref.child("users").child(uid).setValue(["firstname": firstName, "lastname": lastName, "uid": uid, "isAdmin":false])
                        
                        
                        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as?
                        HomeViewController
                        
                        self.view.window?.rootViewController = homeViewController
                        self.view.window?.makeKeyAndVisible()
                }

            }
            
            
           
}
}
}
                    
                    
                    
                     
            
