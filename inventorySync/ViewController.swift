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
let computerCsv = "computerList"
let scriptFilePath = Bundle.main.path(forResource: scriptName, ofType: "py", inDirectory: "python")
let computerListCSV = Bundle.main.path(forResource: "computerList", ofType: "csv", inDirectory: "csv")
let activeCSV = Bundle.main.path(forResource: "ActiveMacs", ofType: "csv", inDirectory: "csv")
let inActiveCSV = Bundle.main.path(forResource: "inActiveMacs", ofType: "csv", inDirectory: "csv")
let webdriver = Bundle.main.path(forResource: "chromedriver", ofType: "", inDirectory: "webdriver")

class ViewController: NSViewController {
    
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet var computerBox: NSScrollView!
    
    
    @IBAction func runScript(_ sender: NSButton) {
        launchScript()
            sleep(25)
            parseCSV()
    }
    
    
    func readDataFromFile(file:String)-> String!{
        guard let filepath = Bundle.main.path (forResource: file, ofType: "csv",  inDirectory: "csv")
            else {return nil}
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
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
        process.arguments = ([scriptFilePath, userName.stringValue, password.stringValue, activeCSV, inActiveCSV, computerListCSV, webdriver]) as? [String]
        process.launch()
        parseCSV()
    }
    
    func parseCSV(){
        var masterList = [readDataFromFile(file: "ActiveMacs")]
        print(masterList[0])
        for computer in masterList {
            computerBox.documentView!.insertNewline(computer)
            computerBox.documentView!.insertText(computer!)
        }
    }
    

}

