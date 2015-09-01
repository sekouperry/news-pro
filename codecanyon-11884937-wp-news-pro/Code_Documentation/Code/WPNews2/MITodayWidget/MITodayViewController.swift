//
//  MITodayViewController.swift
//  MITodayWidget
//
//  Created by Istvan Szabo on 2015. 06. 11..
//  Copyright (c) 2015. Istvan Szabo. All rights reserved.
//

import UIKit
import NotificationCenter

class MITodayViewController: UITableViewController, NCWidgetProviding, NSXMLParserDelegate {
        
    let topBottomWidgetInset: CGFloat = 10.0
    var parser: NSXMLParser = NSXMLParser()
    var newsPosts: [NewsPost] = []
    var postTitle: String = String()
    var postLink: String = String()
    var postAuthor: String = String()
    var postDate: String = String()
    var eName: String = String()
    
    
    var expanded: Bool = false {
        didSet {
            self.tableView.reloadData()
            resetContentSize()
        }
    }
    
    struct TableViewConstants{
        static let cellIdentifier = "MIToday"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func resetContentSize(){
        self.preferredContentSize = tableView.contentSize
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.expanded = false
    }
    
    func onViewMoreButton() {
        self.expanded = true
    }
    
    func performFetch() -> NCUpdateResult{
        
        let url = NSURL(string:WP_FEED_URL)!
        loadRss(url);
        return .NewData
    }
    
    func widgetPerformUpdateWithCompletionHandler(
        completionHandler: ((NCUpdateResult) -> Void)!) {
            
            let result = performFetch()
            
            if result == .NewData{
                tableView.reloadData()
                resetContentSize()
            }
            
            completionHandler(result)
    }
    
    
    func loadRss(data: NSURL) {
        parser = NSXMLParser(contentsOfURL:data)!
        parser.delegate = self
        parser.parse()
        tableView.reloadData()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        eName = elementName
        if elementName == "item" {
            postTitle = String()
            postAuthor = String()
            postDate = String()
            postLink = String()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        let data = string!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (!data.isEmpty) {
            if eName == "title" {
                postTitle += data
            } else if eName == "dc:creator" {
                postAuthor += data
            } else if eName == "pubDate" {
                postDate += data
            } else if eName == "link" {
                postLink += data
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let newsPost: NewsPost = NewsPost()
            newsPost.postTitle = postTitle
            newsPost.postAuthor = postAuthor
            newsPost.postDate = postDate
            newsPost.postLink = postLink
            newsPosts.append(newsPost)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if self.expanded {
            return 6
        }
        return self.newsPosts.count > 4 ? 4 : self.newsPosts.count
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.expanded {
            return 0
        }
        return 60.0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.expanded {
            return UIView(frame: CGRectZero)
        }
        var view = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
        view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 30.0)
        var label = UILabel(frame: CGRectMake(48.0, 0, self.tableView.frame.size.width - 48.0, 30.0))
        view.contentView.addSubview(label)
        label.numberOfLines = 0
        label.textColor = UIColor.lightGrayColor()
        label.text = "See More..."
        label.userInteractionEnabled = true
        var tap = UITapGestureRecognizer(target: self, action: "onViewMoreButton")
        label.addGestureRecognizer(tap)
        
        
        return view
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableViewConstants.cellIdentifier,
            forIndexPath: indexPath) as! MITodayCell
        let newsPost: NewsPost = newsPosts[indexPath.row]
        
        cell.titleLabel.text = newsPost.postTitle
        cell.authorLabel.text = newsPost.postAuthor
        let str = newsPost.postDate
        let stringLength = count(str)
        let substringIndex = stringLength - 14
        str.substringToIndex(advance(str.startIndex, substringIndex))
        cell.dateLabel.text = str.substringToIndex(advance(str.startIndex, substringIndex))
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        let newsPost: NewsPost = newsPosts[indexPath.row]
        let trimmedString = newsPost.postLink.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        println(trimmedString)
      
        self.extensionContext!.openURL(NSURL(string:trimmedString)!, completionHandler: nil)
        }
    
    }
