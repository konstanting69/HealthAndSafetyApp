import UIKit
import Firebase
import Combine
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class AddReportViewController:  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
   
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
   
    

    var ref: DatabaseReference!
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var isUpdationLocation = false
    var lastLocationError: Error?
    //geocoder
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var isPerformingReverseGeocoding = false
    var lastGeocodingError: Error?
    var chosenImage: UIImage?
    
    
  
    


    override func viewDidLoad() {
        super.viewDidLoad()
       
         ref = Database.database().reference()
        
        descriptionTextView.text = "Write description of the incident here.."
        descriptionTextView.textColor = UIColor.black
        descriptionTextView.delegate = self
        let newColor = UIColor.black.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = .some(newColor)
        descriptionTextView.layer.cornerRadius = 5.0
        
        
        
        imageView.layer.borderColor = (newColor)
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 5.0
        
         ref = Database.database().reference()
        
        descriptionTextView.text = "Write description of the incident here.."
        descriptionTextView.textColor = UIColor.black
        descriptionTextView.delegate = self
        
        
        
       
        
        
        
        
       
            
        }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.text == "Write description of the incident here.."{
                   descriptionTextView.textColor = UIColor.black
                   descriptionTextView.text = ""
                   descriptionTextView.returnKeyType = .done
               }
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            descriptionTextView.resignFirstResponder()
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty{
            descriptionTextView.text = "Write description of the incident here.."
            descriptionTextView.textColor = UIColor.black
        }
        
    }

   
    
    
    
    @IBAction func findLocationButtonTapped(_ sender: Any) {
        // 1. Permisson
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        
        if authorisationStatus == .denied || authorisationStatus == . restricted {
            reportLocationServicesDeniedError()
            return
            
        }
        
        
        if isUpdationLocation {
            stopLocationManager()
        }
        else {
            location = nil
                       lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        
        
        
        
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            isUpdationLocation = true
            
        }
        
    }
    func  stopLocationManager() {
        if isUpdationLocation == true {
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func reportLocationServicesDeniedError() {
        let alert = UIAlertController(title: "OOPS!. Location services denied.", message: "Please go to settings to enable location", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    func UpdateLocationTextField() {
       
            if let placemark = placemark {
                locationTextField.text = getAdress(from: placemark)
            } else if isPerformingReverseGeocoding {
                locationTextField.text = "Searching for adress..."
            }else if lastGeocodingError != nil {
                locationTextField.text = "Error finding valid adress!"
                
            } else {
                locationTextField.text = "Adress not found"
                
        }
            
        }
    func getAdress(from placemark:CLPlacemark) -> String{
        
        //Street
        //City, County
        //Country
        var line1 = ""
        if let street1 = placemark.subThoroughfare {
            line1 += street1 + " "
        }
        if let street2 = placemark.thoroughfare {
            line1 += street2
        }
        
        var line2 = ""
        if let city = placemark.locality {
            line2 += city + " "
            
        }
        if let county = placemark.administrativeArea {
            line2 += county + " "
        }
        
        if let postCode = placemark.postalCode {
            line2 += postCode
        }
        var line3 = ""
        if let country = placemark.country {
            line3 += country
        }
        return line1 + "\n" + line2 + "\n" + line3
    }
    
        
    @IBAction func addImageTapped(_ sender: Any) {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
        
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
        else  {
        let ImagePickerController = UIImagePickerController()
        ImagePickerController.delegate = self
        
        
        let actionSheet = UIAlertController(title: "PhotoSource", message: "Choose a source", preferredStyle: .alert)
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
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        self.chosenImage = image
        
        
        picker.dismiss(animated: true, completion: nil)
        
        
        

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        

    }
    
    
 

    
    @IBAction func addReportButton(_ sender: Any) {
        let incidentlocation = locationTextField.text!
        let description = descriptionTextView.text
        let incidentStatus = statusTextField.text
        
              let imageButton = UIImage(systemName: "photo.fill.on.rectangle.fill")
        if descriptionTextView.text == "Write description of the incident here.." || imageView.image == imageButton  || locationTextField.text == "" || statusTextField.text == "" {
                  self.presentAlert(title: "Incident has not been reported", message: "Add all the required information")
              } else {
            
            let userID = Auth.auth().currentUser?.uid
            let newReport = ReportIncidentManager(image: self.chosenImage!, description: description!, location: incidentlocation, status: incidentStatus!,userid: userID!)
              newReport.save()
            presentAlert(title: "Thank you!", message: "The incident has been reported successfully")
                       descriptionTextView.text = "Write description of the incident here.."
                       locationTextField.text = ""
                 statusTextField.text = ""
            imageView.image = imageButton
              }
           
    }
          
          
          func presentAlert(title: String, message: String) {
              let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              present(alert, animated: true)
          }


             
              
          }

extension AddReportViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR! locationManager-didFailWithError: \(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        UpdateLocationTextField()
        
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        print("GOT IT! locationManager-didUpdateLocations: \(String(describing: location))")
        stopLocationManager()
        UpdateLocationTextField()
        if location  != nil {
            
            if !isPerformingReverseGeocoding {
                print("Start performing geocoding...")
                isPerformingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(location!) { (placemarks, error)
                    in
                    self.lastGeocodingError = error
                    if error == nil, let placemarks = placemarks, !placemarks.isEmpty {
                        self.placemark = placemarks.last!
                        
                    }
                    else {
                        self.placemark = nil
                    }
                    self.isPerformingReverseGeocoding = false
                    self.UpdateLocationTextField()
                    
                }
            }
        }
    }
    
}
