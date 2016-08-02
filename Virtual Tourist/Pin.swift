//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 27.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
class Pin: NSManagedObject, MKAnnotation {

    convenience init(latidude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let createEntity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: createEntity, insertIntoManagedObjectContext: context)
            self.longitude = longitude
            self.latidude = latidude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

    //for MKAnnotation stuff
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latidude as! Double, longitude: longitude as! Double)
    }

    func deletePhotosFromPin(stack: CoreDataStack) {
        for photo in photos! {
            stack.context.deleteObject(photo as! NSManagedObject)
        }
    }

}
