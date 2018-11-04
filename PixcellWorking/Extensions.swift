//
//  Extensions.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

//This file contains all the extensions used by the various controllers.

import Foundation

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
        
    func messagePrompt(_ message: String) {
        let ac = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Ok", style: .default)
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension Date {
    
    func getMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    
    func dayMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: self)
    }
    
    
}

public extension FileManager {
    static var documentDirectoryURL: URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
