//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 27.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latidude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSOrderedSet?

}
