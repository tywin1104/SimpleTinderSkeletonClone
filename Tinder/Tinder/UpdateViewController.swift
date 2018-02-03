//
//  UpdateViewController.swift
//  Tinder
//
//  Created by Tianyi Zhang on 2018-01-07.
//  Copyright © 2018 Tianyi Zhang. All rights reserved.
//

import UIKit
import Parse

class UpdateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var userGenderSwitch: UISwitch!
    
    
    @IBOutlet weak var interestedGenderSwitch: UISwitch!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBAction func updateImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func updatedTapped(_ sender: Any) {
        PFUser.current()?["isFemale"] = userGenderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = interestedGenderSwitch.isOn
        
        if let image = profileImageView.image {
            if let imageData = UIImagePNGRepresentation(image) {
                PFUser.current()?["photo"] = PFFile(name: "profile.png", data: imageData)
                PFUser.current()?.saveInBackground(block: {
                    (success, error) in
                    if error != nil {
                        var errorMessage = "Update failed - Try Again"
                        if let newError = error as NSError? {
                            if let detailError = newError.userInfo["error"] as? String {
                                errorMessage = detailError
                            }
                        }
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = errorMessage
                    }else {
                        print("Update Successful!")
                        self.performSegue(withIdentifier: "updateToSwipeSegue", sender: nil)
                       
                        
                    }
                })
            }
            
            
        }
        
        

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        // Do any additional setup after loading the view.
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            userGenderSwitch.setOn(isFemale, animated: false)
        }
        if let isInterestedWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestedGenderSwitch.setOn(isInterestedWomen, animated: false)
        }
        if let photo = PFUser.current()?["photo"] as? PFFile {
            photo.getDataInBackground(block: {
                (data,error) in
                if let imageData = data {
                    if let image = UIImage(data:imageData) {
                        self.profileImageView.image = image
                    }
                    
                }
            })
        }
    }

    

   

}
