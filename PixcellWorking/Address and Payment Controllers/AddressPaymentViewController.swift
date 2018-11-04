//
//  AddressPaymentViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-31.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import LocationPickerViewController
import Firebase
import MapKit

class AddressPaymentViewController: UIViewController {
    
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    var userAddress = ""

    @IBOutlet weak var locationAddressLabel: UITextField!
    @IBOutlet weak var cashOptionPressed: UIButton!
    @IBOutlet weak var creditCardOptionPressed: UIButton!
    @IBOutlet weak var searchLocationButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cashOptionPressed.isEnabled = false
        self.creditCardOptionPressed.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.userAddress = value?["Address"] as? String ?? ""
            //Disable buttons if the address has not been chosen, enable if an address exists
            if self.userAddress == "empty" {
                print("Address is Empty")
            } else {
                self.cashOptionPressed.isEnabled = true
                self.creditCardOptionPressed.isEnabled = true
                self.locationAddressLabel!.text = ("\(self.userAddress)")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickLocationSegue" {
            let locationPicker = segue.destination as! LocationPicker
            locationPicker.addBarButtons()
            locationPicker.pickCompletion = { (pickedLocationItem) in
                guard let addressString = pickedLocationItem.formattedAddressString else {return}
                let locationName = "\(pickedLocationItem.name) \(addressString) Saudi Arabia"
                let locationCoordinates = "\(pickedLocationItem.coordinate!.latitude),\(pickedLocationItem.coordinate!.longitude)"
                guard let uid = Auth.auth().currentUser?.uid else {return}
                self.ref.child("users/\(uid)/Address").setValue(locationName)
                self.ref.child("users/\(uid)/Location Coordinates").setValue(locationCoordinates)
            }
        }
    }

}
