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

//Create data structures
var computers = [[String:String]]()
var dictionaryItems = [String:String]()
//var computers = [[String:String]]()


class ViewController: NSViewController,NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var tableView: NSTableView!
    
    
    func test(){
        print("test")
    }
    //Function to read data from CSV.
    func getData(fileName:String, header1:String, header2:String){
        var data: [[String]] = readDataFromFile(file:fileName).components(separatedBy: "\n").map{ $0.components(separatedBy: ",")}
        for i in 0..<data.count-1 {
            let items = data[i]
            dictionaryItems[header1] = "\(items[0])"
            dictionaryItems[header2] = "\(items[1])"
           // dictionaryItems[header3] = "\(items[2])"
            computers.append(dictionaryItems)
            }
        print(computers)
        
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
        getData(fileName:"ActiveMacs", header1: "serialNumber", header2: "assetTag")
       //  getData(fileName:"inActiveMacs", header1: "serialNumber2", header2: "assetTag2")
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return computers.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var result:NSTableCellView
        result = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        result.textField?.stringValue = computers[row][(tableColumn?.identifier.rawValue)!]!
        return result
    }

}

