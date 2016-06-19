//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 17/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let stack = CoreDataStack(modelName: "Model")!
    
    
    func applicationDidEnterBackground(application: UIApplication) {
        do
        {       try stack.saveContext()
        }catch
        {
            print("Error saving context")
        }
        
    }
    
    
}

