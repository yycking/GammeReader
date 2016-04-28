//
//  ViewController.swift
//  GammeReader
//
//  Created by YehYungCheng on 2016/3/26.
//  Copyright © 2016年 YehYungCheng. All rights reserved.
//

import UIKit
import Fuzi
import SafariServices
import SwiftGifOrigin

class ViewController: UITableViewController {

    var cellHeight = UIScreen.mainScreen().bounds.height
    var data = [[
        "type":"load",
        "link":"https://m.gamme.com.tw/category/all"
        ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.pagingEnabled = true
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .None
        
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl!.addTarget(self, action: #selector(ViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        }
        self.refreshControl!.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        var offset = self.tableView.contentOffset
        var pages = CGFloat(0)
        pages = floor(offset.y / cellHeight)
        
        cellHeight = size.height
        offset.y = cellHeight * pages
        self.tableView.contentOffset = offset
        
        // shift to offset after did Transition
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.tableView.setContentOffset(offset, animated: true)
        }
    }
    
    // MARK: - ViewController
    
    // renew tableview
    func refresh() {
        data = [[
            "type":"load",
            "link":"https://m.gamme.com.tw/category/all"
            ]]
        self.tableView.reloadData()
    }
    
    // download html file and parser to data type of table array
    func downloadHTML(url: String, action: [[String:String]]->()) {
        DownloadManager(url: url) { (html) in
            if let doc = try? HTMLDocument(data: html) {
                var newData = [[String:String]]()
                if let next = doc.firstChild(css: ".nextpostslink") {
                    newData = [[
                        "type" : "load",
                        "link" : next["href"]!
                        ]]
                }
                
                if let first = doc.firstChild(css: ".photo_show") {
                    if let array = self.convertToDate(first) {
                        newData.append(array)
                    }
                }
                for element in doc.css(".news_list li") {
                    if let array = self.convertToDate(element) {
                        newData.append(array)
                    }
                }
                
                action(newData)
            }
        }.connect()
    }
    
    // convert xml to data type of table cell
    func convertToDate(element:XMLElement)->[String:String]?{
        if let text = element.firstChild(css: "h2") {
            var image = ""
            if let img = element.firstChild(css: "img") {
                var src = img["src"]
                src = src!.stringByReplacingOccurrencesOfString("-343x300", withString: "")
                src = src!.stringByReplacingOccurrencesOfString("-144x100", withString: "")
                image = src!
            }
            var link = ""
            if let a = element.firstChild(css: "a") {
                link = a["href"]!
            }
            
            return [
                "type" : "Gamme",
                "text" : text.stringValue,
                "image": image,
                "link" : link
            ]
        }
        
        return nil
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var type:String = "cell"
        if let newType = data[indexPath.row]["type"] {
            type = newType
        }
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(type)
        if cell == nil {
            switch type {
            case "load":
                cell = UITableViewCell(style: .Default, reuseIdentifier: type)
            default:
                cell = PageCell(reuseIdentifier: type)
            }
        }
        cell.tag = indexPath.row
        
        if type == "load" {
            if let url = data[indexPath.row]["link"] {
                self.downloadHTML(url, action: { (newData) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.beginUpdates()
                        let from = self.data.count
                        self.data.appendContentsOf(newData)
                        let to = from + newData.count
                        for index in from...to-1 {
                            self.tableView.insertRowsAtIndexPaths([
                                NSIndexPath(forRow: index, inSection: 0)
                                ], withRowAnimation: .None)
                        }
                        self.tableView.endUpdates()
                    }
                })
                
                data[indexPath.row]["link"] = nil
                self.refreshControl!.endRefreshing()
            }
        } else {
            let cell = cell as! PageCell
            if let text = data[indexPath.row]["text"] {
                cell.textLabel?.text = text
            } else {
                cell.textLabel?.text = ""
            }
            
            cell.setBackground(UIImage.gifWithName("loading")!)
            if let imageUrl = data[indexPath.row]["image"] {
                DownloadManager(url: imageUrl, success: { (imageData) in
                    if let image = UIImage(data: imageData) {
                        if cell.tag == indexPath.row {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                cell.setBackground(image)
                            }
                        }
                    }
                }).connect()
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if data[indexPath.row]["type"] == "load" {
            return 0;
        }
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url = data[indexPath.row]["link"] {
            if let url = NSURL(string: url) {
                let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
}

