//
//  ViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//


//This view controller is the initial view controller and the first thing the user sees when they open the app. From here, they can either login, register, or reset their password.

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet fileprivate var usernameField: UITextField!
    @IBOutlet fileprivate var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //i created a method to hide the keyboard when you tap anywhere else, it is in the extensions file and called under here
        self.hideKeyboardWhenTappedAround()
        usernameField.text = ""
        passwordField.text = ""
    }
    
    //this method tells the view that if the current user token does not equal nil - a user has signed in successfully - to automatically load the home screen
    override func viewDidAppear(_ animated: Bool) {
        let currentUser = Auth.auth().currentUser
        if currentUser != nil && (currentUser?.isEmailVerified)!{
            loadHomeScreen()
        }
    }
    
    //loads home screen LoggedInViewController
    func loadHomeScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loggedInViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
        self.present(loggedInViewController, animated: true, completion: nil)
    }
    
    
    //displays error message for login process using UIAlertController
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
    
    // The sign in method button below takes the user's username and password, and uses firebase's Auth.auth().signIn function to log the user in. It loads the spinner, executes the login and if login fails returns the error message, if it succeeds and the user token does not equal nil - a user is logged in - then it loads the home screen - LoggedInViewController
    @IBAction func signIn (_ sender: UIButton) {
        guard let email = usernameField.text, let password = passwordField.text else {
            return
        }
        let sv = UIViewController.displaySpinner(onView: self.view)
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            UIViewController.removeSpinner(spinner: sv)
            if authResult?.user != nil && (authResult?.user.isEmailVerified)!{
                self.loadHomeScreen()
            } else if authResult?.user != nil && (authResult?.user.isEmailVerified)! == false {
                let ac = UIAlertController(title: "Please Verify Your Email to Login", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(ac, animated: true)
            } else {
                if let descrip = error?.localizedDescription {
                    self.displayErrorMessage(message: descrip)
                }
            }
        }
    }
    
    //This function resets the user's password by using a UIAlertController and having the user enter their recovery email to send the link to using firebases's Auth.auth().sendPasswordReset. If error does not equal nil, that means there is an error and a local error message is returned, else an email is sent.
    @IBAction func resetPassword (_ sender: UIButton) {
        let alert = UIAlertController(title: "Password Reset", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Recovery Email"
            textField.enablesReturnKeyAutomatically = true
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            let sv = UIViewController.displaySpinner(onView: self.view)
            guard let email = alert.textFields![0].text else {
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) {(error) in
                UIViewController.removeSpinner(spinner: sv)
                if error != nil  {
                    self.displayErrorMessage(message: error!.localizedDescription)
                    return
                } else {
                    print("Sent")
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

