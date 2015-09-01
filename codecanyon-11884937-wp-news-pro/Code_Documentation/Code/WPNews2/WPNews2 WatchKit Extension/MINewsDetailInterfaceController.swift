//
//  MINewsDetailInterfaceController.swift
//  WPNews2 WatchKit Extension
//
//  Created by Istvan Szabo on 2015. 06. 15..
//  Copyright (c) 2015. Istvan Szabo. All rights reserved.
//

import WatchKit

class MINewsDetailInterfaceController: WKInterfaceController {
    
   
    @IBOutlet weak var interfaceLabelDescription: WKInterfaceLabel!
    @IBOutlet weak var interfaceImage: WKInterfaceImage!
    
	override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let theData = context as? NewsPostWatch{
            
            if count(theData.postImageLink) == 0{
                
                interfaceImage.setHeight(1.0)
            
            }
            
            interfaceLabelDescription.setText(theData.postDescription.stringByDecodingNewsHTMLEntities() ?? "")
            
           // println(theData.postTitle)
            
            self.setTitle(theData.postTitle)
            
            let imageCacheManager = MIImageDeviceCache()
            
            if imageCacheManager.containsImageInCache(theData.postImageLink){
                interfaceImage.setImageNamed(theData.postImageLink)
                
            }else{
                
                if let aURL = NSURL(string: theData.postImageLink){
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                        
                        let imageData = NSData(contentsOfURL: aURL)
                        
                        dispatch_async(dispatch_get_main_queue()){
                            if imageData?.length > 0{
                                let image = UIImage(data: imageData!)!
                                self.interfaceImage.setImage(image)
                                
                                imageCacheManager.addImageToCache(image, name: theData.postImageLink)
                            }
                        }
                    }
                }
            }
        
        }
        
    }

}


