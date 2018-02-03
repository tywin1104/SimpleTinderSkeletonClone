//
//  LogInViewController.swift
//  Tinder
//
//  Created by Tianyi Zhang on 2018-01-07.
//  Copyright © 2018 Tianyi Zhang. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {

    var signUpMode = false 
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInSignUpButton: UIButton!
    @IBOutlet weak var changeLogInSignUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func LogInSignUpTapped(_ sender: Any) {
        if signUpMode{
            let user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            user.signUpInBackground(block: {
                (success, error)  in
                if error != nil {
                    var errorMessage = "Sign up failed - Try Again"
                    if let newError = error as NSError? {
                        if let detailError = newError.userInfo["error"] as? String {
                            errorMessage = detailError
                        }
                    }
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = errorMessage
                }else {
                    print("Sign Up Successful!")
                    self.performSegue(withIdentifier: "updateSegue", sender: nil)
                }
            })
        }else {
            if let username = usernameTextField.text {
                if let password = passwordTextField.text {
                    PFUser.logInWithUsername(inBackground: username, password: password, block: {
                        (user,error) in
                        if error != nil {
                            var errorMessage = "Log In Failed - Try Again"
                            if let newError = error as NSError? {
                                if let detailError = newError.userInfo["error"] as? String {
                                    errorMessage = detailError
                                }
                            }
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                        }else {
                            print("Log In Successful!") 
                            self.performSegue(withIdentifier: "updateSegue", sender: nil)
                        }
                    })

                }
            }
            
        }
    }

    @IBAction func changeLogInSignUpButtonTapped(_ sender: Any) {
        if signUpMode {
            logInSignUpButton.setTitle("Log In", for: .normal)
            changeLogInSignUpButton.setTitle("Sign Up", for: .normal)
            signUpMode = false
        }else {
            logInSignUpButton.setTitle("Sign Up", for: .normal)
            changeLogInSignUpButton.setTitle("Log In", for: .normal)
            signUpMode = true
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            if PFUser.current()?["isFemale"] != nil {
                self.performSegue(withIdentifier: "LogInToSwipeSegue", sender: nil)
            }else {
                self.performSegue(withIdentifier: "updateSegue", sender: nil)
            }
          
            
            
        }
    }
 

   

}
