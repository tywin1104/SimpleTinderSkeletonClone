//
//  ViewController.swift
//  Tinder
//
//  Created by Tianyi Zhang on 2018-01-07.
//  Copyright © 2018 Tianyi Zhang. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    var displayUserID = ""
    
    @IBOutlet weak var matchImageView: UIImageView!
    @IBAction func logOutTapped(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "LogOutSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        matchImageView.addGestureRecognizer(gesture)
        updateImage()
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        matchImageView.center = CGPoint(x: view.bounds.width/2 + labelPoint.x, y: view.bounds.height/2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width/2 - matchImageView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter/200)
        let scale = min(100 / abs(xFromCenter),1)
        
        var scaleAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        matchImageView.transform = scaleAndRotated
        
        if gestureRecognizer.state == .ended {
            
            var acceptedOrRejected = ""
            
            if matchImageView.center.x < (view.bounds.width/2 - 100) {
                print("Not interested")
                acceptedOrRejected = "rejected"
            }
            if matchImageView.center.x < (view.bounds.width/2 + 100) {
                print("interested")
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" && displayUserID != ""  {
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOrRejected)
                PFUser.current()?.saveInBackground(block: {
                    (success, error) in
                    if success {
                        self.updateImage()
                    }
                })
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            scaleAndRotated = rotation.scaledBy(x: 1, y: 1)
            matchImageView.transform = scaleAndRotated
            
            matchImageView .center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        }
    }
    
    func updateImage() {
        if let query = PFUser.query()  {
            if let isInterestedInWomen = PFUser.current()?["isInterestedWomen"] {
                query.whereKey("isFemale", equalTo: isInterestedInWomen)
            }
            
            if let isFemale = PFUser.current()?["isFemale"] {
                query.whereKey("isInterestedInWomen", equalTo: isFemale)
            }
            
            var ignoredUsers :[String] = []
            
            if let acceptedUsers = PFUser.current()?["accepted"] as? [String] {
                ignoredUsers += acceptedUsers
            }
            if let rejectedUsers = PFUser.current()?["rejected"] as? [String] {
                ignoredUsers += rejectedUsers
            }
            query.whereKey("objectId", notContainedIn: ignoredUsers)
            query.limit = 1
            query.findObjectsInBackground(block: {
                (objects, error) in
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            if let imageFile = user["photo"] as? PFFile {
                                imageFile.getDataInBackground(block: {
                                    (data, error) in
                                    if let imageData = data {
                                        self.matchImageView.image = UIImage(data:imageData)
                                        if let objectID = object.objectId {
                                            self.displayUserID = objectID
                                        }
                                        
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    
}


