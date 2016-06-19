//
//  Photos+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 19/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photos {

    @NSManaged var filePath: String?
    @NSManaged var photo: NSData?
    @NSManaged var location: Pins?

}
