//
//  ViewController.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 3/15/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Cocoa
import Foundation


// Global Variables
let serverURL = "https://ecsu-jss.easternct.edu:8443/JSSResource/"
var doNotRun: String!


let scriptName = "exportFromEquip"
let computerCsv = "computerList"
let scriptFilePath = Bundle.main.path(forResource: scriptName, ofType: "py", inDirectory: "python")
let computerListCSV = Bundle.main.path(forResource: "computerList", ofType: "csv", inDirectory: "csv")
let activeCSV = Bundle.main.path(forResource: "ActiveMacs", ofType: "csv", inDirectory: "csv")
let inActiveCSV = Bundle.main.path(forResource: "inActiveMacs", ofType: "csv", inDirectory: "csv")
let webdriver = Bundle.main.path(forResource: "chromedriver", ofType: "", inDirectory: "webdriver")

//Create data structures
var activeComputers = [[String:String]]()
var inActiveComputers = [[String:String]]()
var dictionaryItems = [String:String]()

class ViewController: NSViewController,NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView1: NSTableView!
    @IBOutlet weak var tableView2: NSTableView!
    
    
    var dataSource1 : FirstDataSource!
    var dataSource2 : SecondDataSource!
    
    @IBAction func segueSync(_ sender: NSButton) {
         performSegue(withIdentifier: "jamfLogin", sender: self)
    }
    
    
    func prepareTableViews (){
        dataSource1 = FirstDataSource()
        self.tableView1.dataSource = dataSource1
        self.tableView1.delegate = dataSource1
        dataSource2 = SecondDataSource()
        self.tableView2.dataSource = dataSource2
        self.tableView2.delegate = dataSource2
    }
    
    
    //Function to read data from CSV.
    // inout with -> Void is used to pass an array into a function
    
    func getData(fileName:String, array: inout[[String:String]], header1:String, header2:String) -> Void {
        //computers = [[:]]
        var data: [[String]] = readDataFromFile(file:fileName).components(separatedBy: "\n").map{ $0.components(separatedBy: ",")}
        for i in 1..<data.count-1 {
            let items = data[i]
            dictionaryItems[header1] = "\(items[0])"
            dictionaryItems[header2] = "\(items[1])"
           // dictionaryItems[header3] = "\(items[2])"
            array.append(dictionaryItems)
            }
    }
    
    
    func readDataFromFile(file:String)-> String!{
        guard let filepath = Bundle.main.path (forResource: file, ofType: "csv",  inDirectory: "csv")
            else {return nil}
        do {
            var contents = try String(contentsOfFile: filepath)
            contents = contents.replacingOccurrences(of: "\r", with: "\n")
            contents = contents.replacingOccurrences(of: "\n\n", with: "\n")
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
  

    override func viewDidLoad() {
        super.viewDidLoad()
      
        //Prepare tables
        prepareTableViews()
        
        //Get Data from CSVs
         getData(fileName:"inActiveMacs", array: &inActiveComputers, header1: "serialNumber", header2: "assetTag")
         getData(fileName:"ActiveMacs", array: &activeComputers, header1: "serialNumber", header2: "assetTag")

    }
    
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
}

