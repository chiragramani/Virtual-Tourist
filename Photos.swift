//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 19/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation
import CoreData


class Photos: NSManagedObject {

    convenience init (pin:Pins,filePath:String,context:NSManagedObjectContext)
    {
        if let entity=NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)
        {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.filePath=filePath
            self.location=pin
        }
        else
        {
            
            fatalError("Entity Photos does not exist")
        }
        
    }


}
