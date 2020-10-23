//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Vicky Zheng on 10/23/20.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                let errorString = error.localizedDescription
                print("Error: \(errorString)")
                // Show the errorString somewhere and let the user try again.
            } else {
                // Hooray! Let them use the app now.
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                let errorString = error!.localizedDescription
                print("Error: \(errorString)")
            }
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
