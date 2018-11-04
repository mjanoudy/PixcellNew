//
//  RegisterViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

//This controller allows the user to register, and is reached from clicking the register button in ViewController.

import UIKit
import Firebase
import Foundation

class RegisterViewController: UIViewController {

    @IBOutlet fileprivate var firstNameField: UITextField!
    @IBOutlet fileprivate var lastNameField: UITextField!
    @IBOutlet fileprivate var emailField: UITextField!
    @IBOutlet fileprivate var passwordField: UITextField!
    @IBOutlet fileprivate var phoneNumbField: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        firstNameField.text = ""
        lastNameField.text = ""
        emailField.text = ""
        passwordField.text = ""
        phoneNumbField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    //This action takes the users inputs for all the fields and unwraps them. Then it displays a spinner while the registration process is going on. If an error occurs, a local error message is generated depending on which field was not filled in correctly. If no error occurs, the spinner disappears and the firebase Auth.auth() method is called to sign up the user with a username and password, then sets up and saves their data in the datastorage under their userID as child perameters.
    
    @IBAction func signUpButton(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text, let firstName = firstNameField.text, let phoneNumb = phoneNumbField.text, let lastName = lastNameField.text else {
            print("Username and Email Not Valid")
            return
        }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        Auth.auth().createUser(withEmail: email, password: password) { (authResult , error) in
            UIViewController.removeSpinner(spinner: sv)
            if let error = error?.localizedDescription{
                self.displayErrorMessage(message: error)
            } else {
                guard let uid = authResult?.user.uid else {
                    if let descrip = error?.localizedDescription{
                        self.displayErrorMessage(message: descrip)
                    }
                    print("failed to load user")
                    return
                }
                let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
                let userRef = ref.child("users").child(uid)
                let values: [String: Any] = ["First Name": firstName,
                                             "Last Name": lastName,
                                             "Phone Number": phoneNumb,
                                             "Email": email,
                                             "Password": password,
                                             "Address": "empty",
                                             "Remaining Photos": 50,
                                             "Extra Album Remaining Photos": 50,
                                             "Second Album Name": "empty",
                                             "Submission Day":0,
                                             "Location Coordinates":"empty"]
                
                userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        if let descrip = error?.localizedDescription{
                            self.displayErrorMessage(message: descrip)
                        }
                        return
                    }
                    Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                        if error != nil {
                            if let descrip = error?.localizedDescription {
                                self.displayErrorMessage(message: descrip)
                            }
                        } else {
                            let ac = UIAlertController(title: "Authentication Email Sent", message: "Please check your junk folder and mark us as safe", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                self.loadLoginScreen()
                            }))
                            self.present(ac, animated: true)
                        }
                    })
                    print("Saved User Successfully")
                })
            }
        }
    }
    
    //method to present the login screen
    func loadLoginScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    //method to show error message
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
}
