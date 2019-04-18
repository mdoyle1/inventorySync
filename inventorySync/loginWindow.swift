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
    @IBAction func login(_ sender: Any) {
        launchScript()
       
        // This needs to be adjusted according to how fast the script can run on a the host computer.
        sleep(25)
        // Sleep longer if app doesn't get data...
        
        performSegue(withIdentifier: "segueLogin", sender: self)
       // self.dismiss(self)
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
  
}

override func viewDidAppear() {
    super.viewDidAppear()
    preferredContentSize = NSSize(width: 480, height: 270)
}
}
