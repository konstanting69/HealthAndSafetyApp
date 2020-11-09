//
//  reportIncidentManager.swift
//  HealthAndSafetyApp
//
//  Created by Konstantin Georgiev on 13/04/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftyJSON

class ReportIncidentManager {

    let userID = Auth.auth().currentUser?.uid
    var description: String!
    var downloadURL: String?
    var location: String!
    var status: String!
    var userid: String!
    private var image: UIImage!
    var reportID : String!
    var imageChanged = false
    
    init(image: UIImage, description: String, location: String, status: String,userid: String){
        self.image = image
        self.description = description
        self.location = location
        self.status = status
        self.userid = userid
    }
    
    init(isImageChange:Bool,image: UIImage, oldURL: String, description: String, location: String, status: String,userid: String,reportID: String){
        self.imageChanged = isImageChange
        self.image = image
        self.downloadURL = oldURL
        self.description = description
        self.location = location
        self.status = status
        self.userid = userid
        self.reportID = reportID
    }
    
    init(snapshot: DataSnapshot){
        let json = JSON(snapshot.value!)
        self.downloadURL = json["downLoadUrl"].string
        self.description = json["description"].stringValue
        self.location = json["location"].stringValue
        self.status = json["status"].stringValue
        self.userid = json["userID"].stringValue
        self.reportID = snapshot.key
    }
   
    func update() {
        
        let newReportRef = Database.database().reference().child("reports").child(reportID)
        let newReportKey = newReportRef.key!
        let storageReference = Storage.storage().reference().child("images/\(newReportKey)")
        let metadata = StorageMetadata()
        if self.imageChanged {
            guard let imageData = image.jpegData(compressionQuality: 0.4) else {
                return
            }
            //delete previous image
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: downloadURL!)
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    print("File deleted successfully")
                }
            }
            
            metadata.contentType = "image/jpg"
            storageReference.putData((imageData as NSData) as Data, metadata: metadata, completion:
              
              { (StorageMetadata, error) in
                  if error == nil {
                      
                      print("shows")
                      storageReference.downloadURL { (url, error) in
                      guard let url = url else {
                          return
                  }
                  print(url.absoluteString)
                  self.downloadURL = url.absoluteString
                  print(self.downloadURL!)
                  let dict = [
                    "downLoadUrl": self.downloadURL!,
                       "description": self.description!,
                       "location": self.location!,
                       "status": self.status!,
                       "userID":self.userid!
                      ] as [String : Any]
                      newReportRef.setValue(dict)
                    //self.presentAlert(title: "Thank you!", message: "The incident has been Updated")
                  }
                      
              }
            })
        } else {
            
            let dict = [
                "downLoadUrl": self.downloadURL! ,
                 "description": self.description!,
                 "location": self.location!,
                 "status": self.status!,
                 "userID":self.userid!
                ] as [String : Any]
                newReportRef.setValue(dict)
                //self.presentAlert(title: "Thank you!", message: "The incident has been Updated")
        }
    }
    
    func save() {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
            
        }
        let newReportRef = Database.database().reference().child("reports").childByAutoId()
        let newReportKey = newReportRef.key!
        let storageReference = Storage.storage().reference().child("images/\(newReportKey)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        storageReference.putData((imageData as NSData) as Data, metadata: metadata, completion:
            
            { (StorageMetadata, error) in
                if error == nil {
                    
                    print("shows")
                    storageReference.downloadURL { (url, error) in
                    guard let url = url else {
                        return

                    
                }
               
                print(url.absoluteString)
               
                self.downloadURL = url.absoluteString
                print(self.downloadURL!)

                let user = Auth.auth().currentUser
                
            
                let dict = [
                    "downLoadUrl": self.downloadURL!,
                     "description": self.description!,
                     "location": self.location!,
                     "status": self.status!,
                     "userID":user!.uid
                    ] as [String : Any]

                        
                    newReportRef.setValue(dict)
                    

                self.presentAlert(title: "Thank you!", message: "The incident has been reported")
                        
                        
                    
                }
                    
            }
        })
    }
            
      
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
    }

}
