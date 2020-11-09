//
//  ViewController.swift
//  HealthAndSafetyApp
//
//  Created by Konstantin Georgiev on 10/04/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ReportTableViewCell: UITableViewCell{
   
    @IBOutlet weak var reportPhotoView: UIImageView!
    @IBOutlet weak var reportLocationLabel: UILabel!
    @IBOutlet weak var reportDescriptionTextView: UITextView!
    @IBOutlet weak var reportStatusLabel: UILabel!

    var report: ReportIncidentManager! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI()  {
        self.reportDescriptionTextView.text = report.description
        self.reportLocationLabel.text = report.location
        self.reportStatusLabel.text = report.status
        let newColor = UIColor.black.cgColor
        reportDescriptionTextView.layer.borderWidth = 1
        reportDescriptionTextView.layer.borderColor = .some(newColor)
        reportDescriptionTextView.layer.cornerRadius = 2
        
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
                            self?.reportPhotoView.image? = image!
                        }
                      
                    }
                }
                print(self!.report.downloadURL as Any)
                
            })
        }
    }
    
    
}


class ReportsTableViewController: UITableViewController {
    var reports = [ReportIncidentManager]()
    var isAdmin = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uid = FirebaseAuth.Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("isAdmin").observeSingleEvent(of: .value) {
            (snapshot) in
            if let admin = snapshot.value as? Bool {
                self.isAdmin = admin
            }
        }
        
        
        
        var reportRef: DatabaseReference!
        reportRef = Database.database().reference().child("reports")
        reportRef.observe(.childAdded) { (snapshot) in
            //call for each of chilren
            // call when there is a new one added
            DispatchQueue.main.async {
                let newReport = ReportIncidentManager(snapshot: snapshot)
                self.reports.insert(newReport, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .top)
                self.tableView.estimatedRowHeight = self.tableView.rowHeight
                self.tableView.rowHeight = UITableView.automaticDimension
            }
        }
        
        //Update table on update
        Database.database().reference().child("reports").observe(.childChanged, with: { (snapshot) in
            if let index = self.reports.firstIndex(where: {$0.reportID == snapshot.key}) {
                var model = self.reports[index]
                model = ReportIncidentManager(snapshot: snapshot)
                self.reports.remove(at: index)
                self.reports.insert(model, at: index)
                self.tableView.reloadData()
            }
        })
        
        //delete record on delte
        Database.database().reference().child("reports").observe(.childRemoved, with: { (snapshot) in
            if let index = self.reports.firstIndex(where: {$0.reportID == snapshot.key}) {
                self.reports.remove(at: index)
                self.tableView.reloadData()
            }
        })
        // parse each of the post
        // update the table view
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportDataCell", for: indexPath) as! ReportTableViewCell
        cell.report = self.reports[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let report = self.reports[indexPath.row]
        let uid = FirebaseAuth.Auth.auth().currentUser?.uid
        if report.userid == uid {
            return true
        }
        if self.isAdmin {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let report = self.reports[indexPath.row]
        let uid = FirebaseAuth.Auth.auth().currentUser?.uid
        if report.userid == uid {
            redirectTOEdit(report: report)
            return
        }
        if self.isAdmin {
            redirectTOEdit(report: report)
        }
    }
    
    func redirectTOEdit(report: ReportIncidentManager){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditReportViewController") as! EditReportViewController
        vc.report = report
        self.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid  else {
            return
        }
        let report = self.reports[indexPath.row]
        
        Database.database().reference().child("reports").child(report.reportID).removeValue { (error, ref) in
            if error != nil {
               print("failed")
               return
            }
            print(uid)
            print()
            //self.reports.remove(at: indexPath.row)

           // self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}


