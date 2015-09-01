//
//  MIImageDeviceCache.swift
//  WPNews2 WatchKit Extension
//
//  Created by Istvan Szabo on 2015. 06. 15..
//  Copyright (c) 2015. Istvan Szabo. All rights reserved.
//
import WatchKit

public class MIImageDeviceCache{
    
    private var allImageCaches: [String : NSNumber] = {
        return WKInterfaceDevice.currentDevice().cachedImages as! [String : NSNumber]
        }()
    
    public func addImageToCache(image:UIImage, name:String){
        
        while WKInterfaceDevice.currentDevice().addCachedImage(image, name: name) == false{
            if removeImageFromCache() == false{
                WKInterfaceDevice.currentDevice().removeAllCachedImages()
                WKInterfaceDevice.currentDevice().addCachedImage(image, name: name)
                break
            }
        }
    }
    
    public func containsImageInCache(name:String) -> Bool{
        return contains(allImageCaches.keys, name)
    }
    
    private func removeImageFromCache() -> Bool{
        let cacheAllKeys = allImageCaches.keys
        
        if let firstCacheName = cacheAllKeys.first{
            WKInterfaceDevice.currentDevice().removeCachedImageWithName(firstCacheName)
            return true
        }
        return false
    }
    
}
