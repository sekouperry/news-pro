//
//  InterfaceController.swift
//  WPNews2 WatchKit Extension
//
//  Created by Istvan Szabo on 2015. 06. 15..
//  Copyright (c) 2015. Istvan Szabo. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, NSXMLParserDelegate  {

    @IBOutlet var newsTable: WKInterfaceTable!
    var parser: NSXMLParser = NSXMLParser()
    var newsPostsWatch: [NewsPostWatch] = []
    var postTitle: String = String()
    var postImageLink: String = String()
    var postAuthor: String = String()
    var postDate: String = String()
    var postDescription: String = String()
    var eName: String = String()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let url = NSURL(string:"http://csongradpress.hu/NewsAppData/?feed=rss2")!
        loadRss(url);
        
        // Configure interface objects here.
    }
    
    func loadRss(data: NSURL) {
        parser = NSXMLParser(contentsOfURL:data)!
        parser.delegate = self
        parser.parse()
        loadTableData()
    
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        eName = elementName
        if elementName == "item" {
            postTitle = String()
            postAuthor = String()
            postDate = String()
            postDescription = String()
            postImageLink = String("")
        } else if elementName == "media:thumbnail" {
            postImageLink = attributeDict["url"] as! String
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
            }else if eName == "content:encoded" {
                postDescription += data
            }else if eName == "media:thumbnail" {
                postImageLink += data
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let newsPostWatch: NewsPostWatch = NewsPostWatch()
            newsPostWatch.postTitle = postTitle
            newsPostWatch.postAuthor = postAuthor
            newsPostWatch.postDate = postDate
            newsPostWatch.postDescription = postDescription
            newsPostWatch.postImageLink = postImageLink
            newsPostsWatch.append(newsPostWatch)
        }
    }
    
    
    private func loadTableData() {
        
        newsTable.setNumberOfRows(newsPostsWatch.count, withRowType: "MINewsTableRowController")
        
        for (index, newsPost) in enumerate(newsPostsWatch) {
            
            let row = newsTable.rowControllerAtIndex(index) as! MINewsTableRowController
            let currentDevice = WKInterfaceDevice.currentDevice()
            let sizeCategory = currentDevice.preferredContentSizeCategory
            
            row.interfaceLabel.setText(newsPost.postTitle)
            
            
            //println(newsPost.postTitle)
            //println(newsPost.postDescription)
            if count(newsPost.postImageLink) == 0{
                row.interfaceImage.setHidden(true)
                
                if sizeCategory == "UICTContentSizeCategoryL" {
                    println("This is the big watch")
                    row.interfaceLabel.setWidth(144)
                    row.interfaceLabel.setHeight(38)
                }
                
                if sizeCategory == "UICTContentSizeCategoryS" {
                    println("This is the small watch")
                    row.interfaceLabel.setWidth(132)
                    row.interfaceLabel.setHeight(38)
                }
                
            }
            let imageCacheManager = MIImageDeviceCache()
            
            if imageCacheManager.containsImageInCache(newsPost.postImageLink){
                row.interfaceImage.setImageNamed(newsPost.postImageLink)
                
            }else{
                
                if let aURL = NSURL(string: newsPost.postImageLink){
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                        
                        let imageData = NSData(contentsOfURL: aURL)
                        //row.interfaceImage.setImageNamed("photo-placeholder")
                            dispatch_async(dispatch_get_main_queue()){
                            if imageData?.length > 0{
                                let image = UIImage(data: imageData!)!
                                 row.interfaceImage.setImage(image)
                                
                                imageCacheManager.addImageToCache(image, name: newsPost.postImageLink)
                            }
                        }
                    }
                }
            }
        }
    }
        
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject?
    {
        let newsPost: NewsPostWatch = newsPostsWatch[rowIndex];
        self.pushControllerWithName("MINewsDetailInterfaceController", context: newsPost)
        return newsPost
    }


    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
