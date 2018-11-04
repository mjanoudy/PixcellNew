//
//  LoggedInViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

//This controller is what the user sees after logging in and/or finishing picking their photos

import UIKit
import Firebase

class LoggedInViewController: UIViewController {
    
    var RemainingImagesCounter: Int?
    var secondAlbumRemainingImagesCounter: Int?
    
    // Creating Firebase Reference for Read/Write Operations
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid

    @IBOutlet var LogOutButton: UIButton!
    @IBOutlet var firstAlbumRemaingingImageLabel: UILabel!
    @IBOutlet var firstAlbumObject: UIView!
    @IBOutlet var firstAlbumStatusLabel: UILabel!
    @IBOutlet var firstAlbumNameLabel: UILabel!
    @IBOutlet var secondAlbumObject: UIView!
    @IBOutlet var secondAlbumStatusLabel: UILabel!
    @IBOutlet var secondAlbumNameLabel: UILabel!
    @IBOutlet var secondAlbumRemainingImageLabel: UILabel!
    @IBOutlet var addAlbumButtonPressed: UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LogOutButton.layer.cornerRadius = 10
        addAlbumButtonPressed.layer.cornerRadius = 10
        self.hideKeyboardWhenTappedAround()
        firstAlbumObject.isHidden = true
        secondAlbumObject.isHidden = true
        firstAlbumObject.layer.cornerRadius = 10
        secondAlbumObject.layer.cornerRadius = 10
        secondAlbumStatusLabel.text = "Selecting Images"
        firstAlbumNameLabel.text = "\(Date().getMonthName())"
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.RemainingImagesCounter = value?["Remaining Photos"] as? Int ?? 0
            self.secondAlbumRemainingImagesCounter = value?["Extra Album Remaining Photos"] as? Int ?? 0
            if self.RemainingImagesCounter! < 50 {
                self.firstAlbumObject.isHidden = false
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //reading from Firebase to get the Remaining Photos
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.RemainingImagesCounter = value?["Remaining Photos"] as? Int ?? 0
            self.secondAlbumRemainingImagesCounter = value?["Extra Album Remaining Photos"] as? Int ?? 0
            self.secondAlbumNameLabel.text = value?["Second Album Name"] as? String ?? "Other Album"
            self.firstAlbumRemaingingImageLabel.text = "\(50-self.RemainingImagesCounter!)/50"
            self.secondAlbumRemainingImageLabel.text = "\(50-self.secondAlbumRemainingImagesCounter!)/50"
            if self.RemainingImagesCounter! < 50 && self.RemainingImagesCounter! > 0 {
                self.firstAlbumObject.isHidden = false
                self.firstAlbumStatusLabel.text = "Selecting Images"
            } else if self.RemainingImagesCounter! == 0 {
                self.firstAlbumStatusLabel.text = "Ready to Submit"
                self.firstAlbumObject.isHidden = false
            }
            if self.secondAlbumRemainingImagesCounter! < 50 && self.secondAlbumRemainingImagesCounter! > 0 {
                self.secondAlbumObject.isHidden = false
                self.secondAlbumStatusLabel.text = "Selecting Images"
            } else if self.secondAlbumRemainingImagesCounter! == 0 {
                self.secondAlbumStatusLabel.text = "Ready to Submit"
                self.secondAlbumObject.isHidden = false
            }
        })

    }
    
    //display an error message as a UIAlertController
    func displayErrorMessage(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) in }
        alertView.addAction(okAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    //loads the main login page - ViewController
    func loadLoginScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    //Logout IBAction to sign the user out. The Auth.auth() method is part of the Firebase pod.
    
    @IBAction func logOut(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            loadLoginScreen()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func firstAlbumSelectImages(_ sender: Any) {
        performSegue(withIdentifier: "PickImagesSegue", sender: UIButton.self)
    }
    
    @IBAction func secondAlbumSelectImages(_ sender: Any) {
        performSegue(withIdentifier: "PickImagesSegue", sender: UIButton.self)
    }
    
    @IBAction func addAlbumButtonPressed(_ sender: Any) {
        if firstAlbumObject.isHidden {
            firstAlbumObject.isHidden = false
        } else if !firstAlbumObject.isHidden && RemainingImagesCounter == 0 {
            let nameSelectionAlert = UIAlertController(title: "Pick a name for your extra Album", message: nil, preferredStyle: .alert)
            nameSelectionAlert.addTextField { (textField) in
                textField.placeholder = "Enter Album Name Here"
                textField.enablesReturnKeyAutomatically = true
            }
            nameSelectionAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                guard let name = nameSelectionAlert.textFields![0].text else {
                    return
                }
                self.secondAlbumNameLabel.text = name
                self.ref.child("users/\(self.uid)/Second Album Name").setValue(name)
                self.secondAlbumObject.isHidden = false
            }))
            present(nameSelectionAlert, animated: true)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let imagesRemaining = RemainingImagesCounter else {return}
        guard let secondImagesRemainingCounter = secondAlbumRemainingImagesCounter else {return}
        if segue.identifier == "PickImagesSegue" && imagesRemaining < 50 {
            if let dest = segue.destination as? CustomAssetCellController {
                dest.imagesRemaining = imagesRemaining
                dest.secondAlbumImagesRemaining = secondImagesRemainingCounter
            }
        }
    }
    
}
