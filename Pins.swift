//
//  Pins.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 19/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pins: NSManagedObject {

    convenience init (annotation:MKAnnotation,context:NSManagedObjectContext)
    {
        if let entity=NSEntityDescription.entityForName("Pins", inManagedObjectContext: context)
        {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.latitude=annotation.coordinate.latitude
            self.longitude=annotation.coordinate.longitude
            
        }
        else
        {
            
            fatalError("Entity Pins does not exist")
        }
        
    }

}
