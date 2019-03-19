//
//  ViewController.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 3/15/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Cocoa
import Foundation


let scriptName = "exportFromEquip"
var filePath = Bundle.main.path(forResource: scriptName, ofType: "py", inDirectory: "python")


class ViewController: NSViewController {
    
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBAction func runScript(_ sender: NSButton) {
        launchScript()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func launchScript(){
        let process = Process()
        process.launchPath = "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3"
        // process.currentDirectoryPath = "\(scriptFilePath)"
        process.arguments = ([filePath, userName.stringValue, password.stringValue] as! [String])
        process.launch()
    }
    

}

