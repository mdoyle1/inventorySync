//
//  ViewController.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 3/15/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Cocoa
import Foundation

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
// Global Variables
let serverURL = "https://ecsu-jss.easternct.edu:8443/JSSResource/"
var doNotRun: String!

var globalServerURL = "https://ecsu-jss.easternct.edu:8443/JSSResource/"
var globalAttributeType: String!
var globalServerCredentials: String!
var globalPathToCSV: NSURL!
var globalCSVPath = activeCSV
var globalCSVContent: String!
var globalParsedCSV: CSwiftV!
var globalXMLDevice: String!
var globalEndpoint: String!
var globalIDType: String!
var globalEndpointID: String!
var delimiter = ","
var columnChecker = 0
var verified = false
var globalHTTPFunction: String!
let myOpQueue = OperationQueue()
let scriptName = "exportFromEquip"
let computerCsv = "computerList"
let scriptFilePath = Bundle.main.path(forResource: scriptName, ofType: "py", inDirectory: "python")
let computerListCSV = Bundle.main.path(forResource: "computerList", ofType: "csv", inDirectory: "csv")
let activeCSV = Bundle.main.path(forResource: "ActiveMacs", ofType: "csv", inDirectory: "csv")
let inActiveCSV = Bundle.main.path(forResource: "inActiveMacs", ofType: "csv", inDirectory: "csv")
let webdriver = Bundle.main.path(forResource: "chromedriver", ofType: "", inDirectory: "webdriver")
 var myURL: URL!
var globalDebug = "off"

//Create data structures
var activeComputers = [[String:String]]()
var inActiveComputers = [[String:String]]()
var dictionaryItems = [String:String]()


// Pass back the CSV Path
func parseCSV() {
    //globalCSVPath = txtCSV.stringValue
    // Parse the CSV into an array
    globalCSVContent = try! NSString(contentsOfFile: globalCSVPath!, encoding: String.Encoding.utf8.rawValue) as String?
    globalParsedCSV = CSwiftV(with: globalCSVContent as String, separator: delimiter, headers: ["Device", "Attribute"])
    
    let columnCheck = globalParsedCSV.rows[0]
    let numberOfCommas = columnCheck.split(separator: delimiter, omittingEmptySubsequences: false)
    let newNumberOfCommas = numberOfCommas[0]
    columnChecker = newNumberOfCommas.count
    print(globalCSVContent)
}

func displayPreFlightInfo() {
    print("Found \(globalParsedCSV.rows.count) rows in the CSV.")
  
    if columnChecker < 2 {
        print("The MUT did not find at least two columns in your CSV. If you are trying to blank out values, please include headers so that it can find the second column.")
        
    } else if columnChecker > 2 {
        print("The MUT found more than two columns in your CSV. The first column should be your unique identifier (eg: serial) and the second column should be the value to be updated.")
        
    } else {
        // Display a preview of row 1 if only 1 row, or row 2 otherwise (to not preview headers)
        if globalParsedCSV.rows.count > 1 {
            let line1 = globalParsedCSV.rows[1]
            if line1.count >= 2 {
                print("Example row from your CSV:")
                print("\(globalIDType!.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType!): \(line1[1])")
            } else {
                print("Not enough columns were found in your CSV!!!")
                print("You can set a custom delimiter under Settings in the menu bar if you wish.")
            }
        } else if globalParsedCSV.rows.count > 0 {
            let line1 = globalParsedCSV.rows[0]
            if line1.count >= 2 {
                print("Example row from your CSV:")
                print("\(globalIDType.replacingOccurrences(of: " ", with: "")): \(line1[0]), \(globalAttributeType!): \(line1[1])")
            } else {
                print("Not enough columns were found in your CSV!!!")
                print("You can set a custom delimiter under Settings in the menu bar if you wish.")
            }
        } else {
            print("No rows found in your CSV!!!")
        }

    }
    
}


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
        for i in 0..<data.count-1 {
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

    func prepareToBuildXML() {
        // Switches to set Identifier type
        if globalParsedCSV.rows.count > 0 {
            let row1 = globalParsedCSV.rows[0]
            if globalParsedCSV.rows.count > 1 {
                // MORE THAN ONE ROW, LOGICAL DETERMINATIONS
                let row2 = globalParsedCSV.rows[1]
                //macOS
                if globalXMLDevice == "computer" {
                    if row2[0].isNumber {
                        //print("logically it is an ID")//uncomment for debugging
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        print("MUT has logically detected IDs for the unique identifier.")
                        print("")
                        print("To override: include a header row specifying 'id' or 'serial' in Column A.")
                    } else {
                        //print("logically it is a serial")//uncomment for debugging
                        globalIDType = "Serial Number"
                        globalEndpointID = "serialnumber"
                        print("MUT has logically detected Serial Numbers for the unique identifier.")
                        print("")
                        print("To override: include a header row specifying 'id' or 'serial' in Column A.")
                    }
                   
                }
         
            } else {
                // ONLY ONE ROW, LOGICAL DETERMINATIONS
                //macOS
                if globalXMLDevice == "computer" {
                    if row1[0].isNumber {
                        globalIDType = "ID"
                        globalEndpointID = "id"
                        print("MUT has logically detected IDs for the unique identifier.")
                        print("")
                        print("To override: include a header row specifying 'id' or 'serial' in Column A.")
                    } else {
                        globalIDType = "Serial Number"
                        globalEndpointID = "serialnumber"
                        print("MUT has logically detected Serial Numbers for the unique identifier.")
                       print("")
                        print("To override: include a header row specifying 'id' or 'serial' in Column A.")
                    }
                   print("")
                }
               
            }
            if row1[0].lowercased() == "id" {
                globalEndpointID = "id"
                globalIDType = "ID"
                print("Your header specifying IDs overrides the previous logical determination.")
            }
            if row1[0].lowercased().contains("serial") {
                globalEndpointID = "serialnumber"
                globalIDType = "Serial Number"
                print("Your header specifying Serial Numbers overrides the previous logical determination.")
    
            }
        }
    }
    

