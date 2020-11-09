//
//  HomePageViewController.swift
//  HealthAndSafetyApp
//
//  Created by Konstantin Georgiev on 20/04/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomePageViewController: UIViewController {

    @IBOutlet weak var txtHome: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let newColor = UIColor.white.cgColor
        txtHome.layer.borderWidth = 1
        txtHome.layer.borderColor = .some(newColor)
        txtHome.layer.cornerRadius = 2
        txtHome.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func logOutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: .alert)

       alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
        self.logOut()
        self.toLogInViewController()
        
        
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        
        
      
        
    }
    
    func toLogInViewController() {
         let logInViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.logInViewContoller) as?
         LogInViewController
         self.view.window?.rootViewController = logInViewController
         self.view.window?.makeKeyAndVisible()
    }
    func logOut() {
    let firebaseAuth = Auth.auth()
               do {
                 try firebaseAuth.signOut()
                   
               } catch let signOutError as NSError {
                 print ("Error signing out: %@", signOutError)
               }
    
    }
}
