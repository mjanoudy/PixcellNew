//
//  PaymentViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-28.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class PaymentViewController: UIViewController {
    
    // MARK: Instance Variables
    var initialSetupViewController: PTFWInitialSetupViewController!
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    var userEmail = ""
    var userPhone = ""

    
    //let user = Auth.auth().currentUser
    @IBOutlet weak var responseCodeLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var transactionIDLabel: UILabel!
    @IBOutlet weak var customerEmailLabel: UILabel!
    @IBOutlet weak var customerPasswordLabel: UILabel!
    @IBOutlet weak var transactionStateLabel: UILabel!
    @IBOutlet weak var tokenValueLabel: UILabel!
    @IBOutlet weak var responseView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseView.isHidden = true
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.userEmail = value?["Email"] as? String ?? ""
            self.userPhone = value?["Phone Number"] as? String ?? ""
        })
    }
    
    
    
    private func initiateSDK() {
        
        let bundle = Bundle(url: Bundle.main.url(forResource: ApplicationResources.kFrameworkResourcesBundle, withExtension: "bundle")!)

        // Mark: Initialize the paytabs SDK with all the required parameters
        
        self.initialSetupViewController = PTFWInitialSetupViewController.init(nibName: "Resources", bundle: bundle, andWithViewFrame: self.view.frame, andWithAmount: 25.00, andWithCustomerTitle: "Paytabs", andWithCurrencyCode: "SAR", andWithTaxAmount: 0, andWithSDKLanguage: "en", andWithShippingAddress: "2475 Ibn Ayub Shafi Road", andWithShippingCity: "Jeddah", andWithShippingCountry: "SAU", andWithShippingState: "Makkah", andWithShippingZIPCode: "22241", andWithBillingAddress: "2475 Ibn Ayub Shafi Road", andWithBillingCity: "Jeddah", andWithBillingCountry: "SAU", andWithBillingState: "Makkah", andWithBillingZIPCode: "22241", andWithOrderID: "0001", andWithPhoneNumber: "00966\(userPhone.dropFirst())", andWithCustomerEmail: userEmail, andIsTokenization: true, andWithMerchantEmail: "mjanoudy@solarbits.com", andWithMerchantSecretKey: "F5IZyLkWJA2ZDXjWeDbbOYvaZB7HiT9XZRXyChumSxlvvFsJjEU7CqhC2pjkjtiikgQXyljqSFWolp7E32MGt3ivtCQM585ppVnX", andWithAssigneeCode: "SDK", andWithThemeColor: UIColor.init(alpha: 1.0, red: 255, green: 255, blue: 255), andIsThemeColorLight: true)
    
        weak var weakSelf = self
        self.initialSetupViewController.didReceiveBackButtonCallback = {
            weakSelf?.handleBackButtonTappedEvent()
        }
        
        
        self.initialSetupViewController.didReceiveFinishTransactionCallback = {(responseCode, result, transactionID, tokenizedCustomerEmail, tokenizedCustomerPassword, token, transactionState) in
            self.responseCodeLabel.text = "\(responseCode)"
            self.resultLabel.text = "\(result)"
            self.transactionIDLabel.text = "\(transactionID)"
            self.customerEmailLabel.text = "\(tokenizedCustomerEmail)"
            self.customerPasswordLabel.text = "\(tokenizedCustomerPassword)"
            self.transactionStateLabel.text = "\(transactionState)"
            self.tokenValueLabel.text = "\(token)"
            
            self.responseView.isHidden = false
            
            weakSelf?.handleBackButtonTappedEvent()
        }
    }
    
    @IBAction func sendPaymentButtonTapped(_ sender: Any?) {
        
        self.initiateSDK()
        let bundle = Bundle(url: Bundle.main.url(forResource: ApplicationResources.kFrameworkResourcesBundle, withExtension: "bundle")!)
        
        if bundle?.path(forResource: ApplicationXIBs.kPTFWInitialSetupView, ofType: "nib") != nil {
            print("exists")
        } else {
            print("not exist")
        }
        
        self.view.addSubview(initialSetupViewController.view)
        self.addChild(initialSetupViewController)
        
        initialSetupViewController.didMove(toParent: self)
    }
    
    private func handleBackButtonTappedEvent() {
        self.initialSetupViewController.willMove(toParent: self)
        self.initialSetupViewController.view.removeFromSuperview()
        self.initialSetupViewController.removeFromParent()
    }
    
    @IBAction func closeResponsePressed(_ sender: Any?){
        self.responseView.isHidden = true
    }
    
    
    func loadPaymentScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "PaymentViewController") as! ViewController
        self.present(viewController, animated: true, completion: nil)
    }

    

}
