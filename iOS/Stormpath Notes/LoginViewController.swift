//
//  LoginViewController.swift
//  Stormpath Notes
//
//  Created by Edward Jiang on 3/11/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit
import Stormpath
import AWSCore

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func login(_ sender: AnyObject) {
        // Login the user
        APIClient.login(username: emailTextField.text!, password: passwordTextField.text!) { error in
            if let error = error {
                self.showAlert(withTitle: "Error", message: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "login", sender: self)
            }
        }
    }
}

// Helper extension to display alerts easily.
extension UIViewController {
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
