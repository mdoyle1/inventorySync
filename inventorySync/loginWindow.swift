//
//  loginWindow.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 4/4/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Cocoa
import Foundation

class loginWindow: NSViewController{

    @IBOutlet var appName: NSTextField!
    @IBOutlet var userName: NSTextField!
    @IBOutlet var password: NSSecureTextField!
    var fileSize : UInt64!
    
    @IBAction func login(_ sender: Any) {
        
        // Warn the user if they forget to put in username or password
        if userName.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Username", text: "Please enter your eQuip username.")
            doNotRun = "1"
        }
        if password.stringValue == "" {
            _ = popPrompt().generalWarning(question: "No Password", text: "Please enter your eQuip password.")
            doNotRun = "1"
        }else {
            doNotRun = "0"
        }
       print(doNotRun)
        if doNotRun != "1" {
            launchScript()
            // This needs to be adjusted according to how fast the script can run on a the host computer.
            sleep(25)
            // Sleep longer if app doesn't get data...
            
            
            //Check to see if the CSV file size has updated.
            fileSizeCheck(filepath:computerListCSV!)
            if fileSize > 1 {
                performSegue(withIdentifier: "segueLogin", sender: self)
            } else { popPrompt().generalWarning(question: "Please check your username or password.", text: "Also, make sure python 3 is installed.  Try extending the script execution time.  If you are still having problems the python script may need to be edited.")
                
            }
            
            
            }
       
       
}
    //Function to check file size.
    func fileSizeCheck(filepath: String!) -> UInt64 {
      
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filepath)
            fileSize = attr[FileAttributeKey.size] as? UInt64
            print("\(String(describing: filepath)) is \(String(describing: fileSize)) byte.")
        } catch {
            print("Error: \(error)")
        }
        return fileSize
    }
    
    func launchScript(){
        let process = Process()
        process.launchPath = "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3"
        // process.currentDirectoryPath = "\(scriptFilePath)"
        process.arguments = ([scriptFilePath, userName.stringValue, password.stringValue, activeCSV, inActiveCSV, computerListCSV, webdriver]) as? [String]
        process.launch()
    }
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
        fileSizeCheck(filepath: computerListCSV!)
      
}

override func viewDidAppear() {
    super.viewDidAppear()
    preferredContentSize = NSSize(width: 480, height: 270)
}
}
