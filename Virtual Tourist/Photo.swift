//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 27.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
class Photo: NSManagedObject {

    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

    convenience init(url: String, id: String, context: NSManagedObjectContext) {
        if let createEntity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: createEntity, insertIntoManagedObjectContext: context)
            self.url = url
            self.id = id
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

    func downloadImageFromFlickrUrl(completionHandler: (image:UIImage!, errorMessage:String?) -> Void) {
        //look if photo is already loaded
        if self.image != nil {
            completionHandler(image: UIImage(data: self.image!)!, errorMessage: nil)
            return
        } else {
            FlickrClient.sharedInstance.loadImageFromUrl(url!) {
                (data, errorMessage) in

                guard (errorMessage == nil) else {
                    completionHandler(image: nil, errorMessage: errorMessage)
                    return
                }

                guard let imageFromData = UIImage(data: data) else {
                    completionHandler(image: nil, errorMessage: "Could not get image from data")
                    return
                }

                self.image = data

                completionHandler(image: imageFromData, errorMessage: errorMessage)
            }
        }
    }


}
