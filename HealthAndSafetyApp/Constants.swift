//
//  Constants.swift
//  HeathAndSafetyApp
//
//  Created by Konstantin Georgiev on 29/03/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//This is the final app

import Foundation
import Firebase

struct Constants {
    
    struct Storyboard {
    
       static let homeViewController  = "HomeVC"
        static let addReportViewController = "AddRepsVC"
        static let logInViewContoller = "logInVC"
        
        
        
        
    }
    
    
}
struct FirebaseReferenceManager {
    static let usersChild = "users"
    static let db = Firestore.firestore()
    static let root = db.collection("reports").document("reports")
    static let reportChild = "reports"
}




