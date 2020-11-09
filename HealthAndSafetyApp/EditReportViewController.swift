//
//  EditReportViewController.swift
//  HealthAndSafetyApp
//
//  Created by Konstantin Georgiev on 17/04/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class EditReportViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate  {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtEditLocation: UITextField!
    @IBOutlet weak var txtStatus: UITextField!
    var imageChanged = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.UpdateUI()
    }

    var report: ReportIncidentManager!
    
    func UpdateUI(){
        self.txtDescription.text = report.description
        self.txtEditLocation.text = report.location
        self.txtStatus.text = report.status
        //download photo
        if let imageDownloadURL = report.downloadURL {
            let imageStorageRef = Storage.storage().reference(forURL: imageDownloadURL)
            imageStorageRef.getData(maxSize: 2*1024*1024, completion:  {[weak self] (data, err) in
                if  err != nil {
                    print("*********ERROR DOWNLOAD ")
                } else{
                    //success
                    if let imageData = data {
                         let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self?.imgView.image? = image!
                        }
                      
                    }
                }
                print(self!.report.downloadURL as Any)
                
            })
        }
    }

    @IBAction func onClick_btnDone(_ sender: Any) {
        let incidentlocation = txtEditLocation.text!
        let description = txtDescription.text
        let incidentStatus = txtStatus.text

        let imageButton = UIImage(systemName: "photo.fill.on.rectangle.fill")
        if txtDescription.text == "" || imgView.image == imageButton  || txtEditLocation.text == "" || txtStatus.text == "" {
            self.presentAlert(title: "Incident has not been reported", message: "Add all the required information")
        } else {
           // let userID = Auth.auth().currentUser?.uid
            let newReport = ReportIncidentManager(isImageChange: imageChanged,image: self.imgView.image!,oldURL : report.downloadURL!, description: description!, location: incidentlocation, status: incidentStatus!,userid: report.userid!,reportID: report.reportID)
            newReport.update()
            //presentAlert(title: "Thank you!", message: "The incident has been reported successfully")
            txtDescription.text = "Write description of the incident here.."
            txtEditLocation.text = ""
            txtStatus.text = ""
            imgView.image = imageButton
            self.dismiss(animated: true, completion: nil)
        }
    }

    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        let ImagePickerController = UIImagePickerController()
        ImagePickerController.delegate = self

        let actionSheet = UIAlertController(title: "PhotoSource", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
           ImagePickerController.sourceType = .camera
           self.present(ImagePickerController, animated: true, completion: nil)

        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            ImagePickerController.sourceType = .photoLibrary
           self.present(ImagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))

        self.present(actionSheet, animated: true, completion: nil)
    }
       
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.imgView.image = image
        self.imageChanged = true
       picker.dismiss(animated: true, completion: nil)
    }
   
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       picker.dismiss(animated: true, completion: nil)
    }
       
       
}
