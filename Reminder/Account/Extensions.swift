//
//  Extensions.swift
//  Reminder
//
//  Created by Yijia Huang on 10/7/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit

/// image cache
let imageCache = NSCache<AnyObject, AnyObject>()

// MARK: - extension of UIimage View
extension UIImageView {
    // MARK: - Methods
    /// load image by using cache with url
    ///
    /// - Parameter urlString: image url
    @objc func loadImageUsingCacheWithURLString(urlString: String) {
        
        /// image
        self.image = nil
        
        // check cache for image first
        
        /// cached image
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // otherwise fire off a new download
        
        /// url
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "err")
                return
            }
            DispatchQueue.main.async(execute: {
                if let downloadImage = UIImage(data: data!) {
                    imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                    self.image = downloadImage
                }
            })
        }).resume()
    }
    
}
