//
//  SecondDataSource.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 4/17/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Cocoa

class SecondDataSource:  NSObject,NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
            return inActiveComputers.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var result = NSTableCellView()
            
            result = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
            result.textField?.stringValue = inActiveComputers[row][(tableColumn?.identifier.rawValue)!]!
            return result
     
    }
   
}
