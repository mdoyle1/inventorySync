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
    
    @IBOutlet weak var barProgress: NSProgressIndicator!
    @IBOutlet weak var lblCurrent: NSTextField!
    @IBOutlet weak var lblOf: NSTextField!
    @IBOutlet weak var lblLine: NSTextField!
    @IBOutlet weak var lblEndLine: NSTextField!
    
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
                            globalServerCredentials = self.base64Credentials
                            print("Updating inventory...")
                            parseCSV()
                            prepareToBuildXML()
                            globalHTTPFunction = "PUT"
                            self.uploadData()
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
    
    @IBAction func CSVtest(_ sender: NSButton) {
        parseCSV()
        prepareToBuildXML()
        globalHTTPFunction = "PUT"
        uploadData()
    }
    
   
    
    // MARK: - UPLOAD DATA FUNCTION
    func uploadData() {
        
        // Async update the UI for the start of the run
        //    DispatchQueue.main.async {
        //        self.beginRunView()
        //    }
        // Declare variables needed for progress tracking
        var rowCounter = 0
        let row = globalParsedCSV.rows // Send parsed rows to an array
        let lastrow = row.count - 1
        var i = 0
        lblEndLine.stringValue = "\(row.count)"
        
        // Set the max concurrent ops to the selectable number
        myOpQueue.maxConcurrentOperationCount = 1
        
        // Semaphore causes the op queue to wait for responses before sending a new request
        let semaphore = DispatchSemaphore(value: 0)
        
        
        while i <= lastrow {
            // Sets the current row to the row of the loop
            let currentRow = row[i]
            
            // Add a PUT or POST request to the operation queue
            myOpQueue.addOperation {
                if globalHTTPFunction == "PUT" {
                    
                    // TODO clean this section up I hate this logic block soooooo much.
                 
                    
                myURL = xmlBuilder().createPOSTURL(url: globalServerURL)
                print(myURL)
                
                let encodedXML = xmlBuilder().createXML(popIdentifier: "serial", popDevice: "macOS Devices", popAttribute: "Asset Tag", eaID: "", columnB: currentRow[1], columnA: currentRow[0])
                
                let request = NSMutableURLRequest(url: myURL)
                request.httpMethod = globalHTTPFunction
                request.httpBody = encodedXML
                    print(request.httpBody as Any)
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(globalServerCredentials!)", "Content-Type" : "text/xml", "Accept" : "text/xml"]
                    print(configuration.httpAdditionalHeaders as Any)
                let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    
                    // If debug mode is enabled, print out the full data from the curl
                    if let myData = String(data: data!, encoding: .utf8) {
                        if globalDebug == "on" {
                            print("Full Response Data:")
                            print(myData)
                            print("")
                        }
                    }
                    // If we got a response
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        // If that response is a success response
                        if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                            DispatchQueue.main.async {
                                // Print information to the log box
                                print("Device \(currentRow[0]) - ")
                               print("OK! - \(httpResponse.statusCode)")
                                // Update the progress bar
                                self.barProgress.doubleValue = Double(rowCounter)
                            }
                        } else {
                            // If that response is not a success response
                            DispatchQueue.main.async {
                                // Print information to the log box
                                print("Device \(currentRow[0]) - ")
                                print("Failed! - \(httpResponse.statusCode)!")
                                if httpResponse.statusCode == 404 {
                                    print("")
                                    print( "HTTP 404 means 'not found'. There is no device with \(globalEndpointID!) \(currentRow[0]) enrolled in Jamf Pro.")
                                    print("")
                                }
                                if httpResponse.statusCode == 409 {
                                    print("")
                                    print("HTTP 409 is a generic error code code. Turn on Advanced Debugging from the settings menu at the top of the screen for more information.")
                                   print("")
                                }
                                // Update the progress bar
                                self.barProgress.doubleValue = Double(rowCounter)
                            }
                        }
                        // Increment the row counter and signal that the response was received
                        rowCounter += 1
                        semaphore.signal()
                        // Async update the row count label
                        DispatchQueue.main.async {
                            self.lblLine.stringValue = "\(rowCounter)"
                        }
                    }
                    // Log errors if received (we probably shouldn't ever end up needing this)
                    if error != nil {
                        _ = popPrompt().generalWarning(question: "Fatal Error", text: "The MUT received a fatal error while uploading. \n\n \(error!.localizedDescription)")
                    }
                })
                    // Send the request and then wait for the semaphore signal
                    task.resume()
                    semaphore.wait()
                    
                    // If we're on the last row sent, update the UI to reset for another run
                    if rowCounter == lastrow || lastrow == 0 {
                        DispatchQueue.main.async {
                            //resetView()
                        }
                    }
                }
                i += 1
            }
        }
                   
}
    
    func beginRunView() {
        print("Beginning Update Run!")
        print("")
        self.lblLine.isHidden = false
        self.lblCurrent.isHidden = false
        self.lblEndLine.isHidden = false
        self.lblOf.isHidden = false
        self.barProgress.isHidden = false
        self.barProgress.maxValue = Double(globalParsedCSV.rows.count)
       // self.btnSubmitOutlet.isHidden = true
        //self.btnCancelOutlet.isHidden = false
    }
    
 
    
    func userDidAuthenticate(base64Credentials: String, url: String) {
        //print(base64Credentials)
        globalServerCredentials = base64Credentials
        //print(url)
        globalServerURL = url
        self.verified = true
    }
}
