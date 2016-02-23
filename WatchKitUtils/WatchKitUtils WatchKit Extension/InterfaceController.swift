//
//  InterfaceController.swift
//  WatchKitUtils WatchKit Extension
//
//  Created by Nguyen Anh Minh on 2/23/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    let connection: Connection! = Connection.getInstance

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
