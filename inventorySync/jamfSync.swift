//
//  jamfSync.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 4/22/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Cocoa
import Foundation

protocol DataSentDelegate {
    func userDidAuthenticate(base64Credentials: String, url: String)
}


class jamfSync: NSViewController, URLSessionDelegate {
    
    //Enable setting login defaults
    let loginDefaults = UserDefaults.standard
    var delegateAuth: DataSentDelegate? = nil
    
    //Username and password fields
    @IBOutlet weak var txtUserOutlet: NSTextField!
    @IBOutlet weak var txtPassOutlet: NSSecureTextField!
    @IBOutlet weak var chkRememberMe: NSButton!
    
    @IBOutlet weak var spinProgress: NSProgressIndicator!
    var base64Credentials: String!
    var verified = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Restore the Username to text box if we have a default stored
        if loginDefaults.value(forKey: "UserName") != nil {
            txtUserOutlet.stringValue = loginDefaults.value(forKey: "UserName") as! String
        }
       
        if loginDefaults.value(forKey: "Remember") != nil {
            if loginDefaults.bool(forKey: "Remember") {
                chkRememberMe.state = NSControl.StateValue(rawValue: 1)
            } else {
                chkRememberMe.state = NSControl.StateValue(rawValue: 0)
            }
        } else {
            // Just in case you ever want to do something for no default stored
        }// Do view setup here.
        
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
       //preferredContentSize = NSSize(width: 450, height: 600)
        // If we have a URL and a User stored focus the password field
        if loginDefaults.value(forKey: "InstanceURL") != nil  && loginDefaults.value(forKey: "UserName") != nil {
            self.txtPassOutlet.becomeFirstResponder()
        }
    }
    
    
//btnSubmit
    @IBAction func syncJamf(_ sender: NSButton) {
        //self.dismiss(self)
        //txtURLOutlet.stringValue = txtURLOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtUserOutlet.stringValue = txtUserOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        txtPassOutlet.stringValue = txtPassOutlet.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        
        // Warn the user if they have failed to enter a username
        if txtUserOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Username Found", text: "It appears that you have not entered a username for Inventory Sync to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        // Warn the user if they have failed to enter a password
        if txtPassOutlet.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Password Found", text: "It appears that you have not entered a password for Inventory Sync to use while accessing Jamf Pro. Please enter your username and password, and try again.")
            doNotRun = "1" // Set Do Not Run flag
        }
        
        // Move forward with verification if we have not flagged the doNotRun flag
        if doNotRun != "1" {
            
            
         //   btnSubmitOutlet.isHidden = true
            spinProgress.startAnimation(self)
            
            // Concatenate the credentials and base64 encode the resulting string
            let concatCredentials = "\(txtUserOutlet.stringValue):\(txtPassOutlet.stringValue)"
            let utf8Credentials = concatCredentials.data(using: String.Encoding.utf8)
            base64Credentials = utf8Credentials?.base64EncodedString()
            
            // MARK - Credential Verification API Call
            
            DispatchQueue.main.async {
                let myURL = xmlBuilder().createGETURL(url: serverURL)
                let request = NSMutableURLRequest(url: myURL)
                request.httpMethod = "GET"
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(self.base64Credentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                            self.verified = true
                            
                            // Store username if button pressed
                            if self.chkRememberMe.state.rawValue == 1 {
                                self.loginDefaults.set(self.txtUserOutlet.stringValue, forKey: "UserName")
                                self.loginDefaults.set(true, forKey: "Remember")
                                self.loginDefaults.synchronize()
                                
                            } else {
                                self.loginDefaults.removeObject(forKey: "UserName")
                                self.loginDefaults.set(false, forKey: "Remember")
                                self.loginDefaults.synchronize()
                            }
                            self.spinProgress.stopAnimation(self)
                            print("Successfully Authenticated With Jamf!")
                            //self.btnSubmitOutlet.isHidden = false
                            
                            if self.delegateAuth != nil {
                                self.delegateAuth?.userDidAuthenticate(base64Credentials: self.base64Credentials!, url: serverURL)
                                self.dismiss(self)
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                self.spinProgress.stopAnimation(self)
                                //self.btnSubmitOutlet.isHidden = false
                                _ = popPrompt().generalWarning(question: "Invalid Credentials", text: "The credentials you entered do not seem to have sufficient permissions. This could be due to an incorrect user/password, or possibly from insufficient permissions. Inventory Sync tests this against the user's ability to view the Activation Code via the API.")
                            }
                        }
                    }
                    if error != nil {
                        _ = popPrompt().generalWarning(question: "Fatal Error", text: "Inventory Sync received a fatal error at authentication. The most common cause of this is an incorrect server URL. The full error output is below. \n\n \(error!.localizedDescription)")
                        self.spinProgress.stopAnimation(self)
                      //  self.btnSubmitOutlet.isHidden = false
                    }
                })
                task.resume()
            }
        } else {
            // Reset the Do Not Run flag so that on subsequent runs we try the checks again.
            doNotRun = "0"
        }
    }
    
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    

    
}
