//
//  gcd_blackbox.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 18/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
}
}