//
//  DemoTable.swift
//  TableDemo
//
//  Created by Raymond van Dongelen on 10-11-14.
//  Copyright (c) 2014 Vooruit met. All rights reserved.
//

import UIKit

class BoekenStore {
    /* Eerst singleton spul */
    class var sharedInstance: BoekenStore {
        struct Static {
            static var instance: BoekenStore?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = BoekenStore()
        }
        
        return Static.instance!
    }
    
    /* Andere dingen */
    var titels : [String]
    init() {
        titels = []
        loadFromServer()
    }
    
    func loadFromServer () {

        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()

        manager.GET( "http://still-brook-6654.herokuapp.com/books.json",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                self.verwerkJSON(JSON(responseObject))
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                println("Error: " + error.localizedDescription)
        })
    }
    
    func verwerkJSON(json:JSON) {
        println (json)
        println ("Aantal boeken \(json.count)")
        
        for (index: String, subJson: JSON) in json {
            //Do something you want
            println ("In loop \(index)")
            println (subJson["title"])
            if let titel = subJson["title"].string {
                voegBoekToe(titel)
            }
        }
    }
    
    
    func count() ->Int {
        return titels.count
    }
    
    func boekAtIndex(index:Int) -> String {
        return titels[index]
    }
    
    func voegBoekToe (titel : String) {
        titels.append(titel)
        NSNotificationCenter.defaultCenter().postNotificationName("NieuwBoek", object: nil)
    }
}
class DemoTable : UITableViewController, UITableViewDataSource {
    
    let CELL_TYPE_ID = "HALLO_VELD"
    let boeken = BoekenStore.sharedInstance

    override func viewDidLoad () {
        self.title = "Boeken"
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadTableData", name:"NieuwBoek", object: nil)
    }
    
    func reloadTableData() {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boeken.count()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCellWithIdentifier(CELL_TYPE_ID) as? UITableViewCell
        
        if (cell == nil) {
            println ("Nieuwe cell aangemaakt bij \(indexPath.row)")

            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: CELL_TYPE_ID)
        }
        
        cell!.textLabel!.text = boeken.boekAtIndex(indexPath.row)
        
        return cell!
    }
    
    
}
