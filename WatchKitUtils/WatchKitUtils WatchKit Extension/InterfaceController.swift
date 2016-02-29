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
    
    var connection: DataTransfer! = nil
    
    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var sendButton: WKInterfaceButton!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
      
        self.connection = DataTransfer.getInstance
        self.connection.addObserver(self, forKeyPath: kConnectionChange, options: NSKeyValueObservingOptions(), context: nil)
        self.connection.connect()
        
        if (self.connection.didReceiveMessage == nil){
            self.connection.didReceiveMessage = { (message) -> Void in
                let msg = message["Message"] as! String?
                if (msg == nil){
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.messageLabel.setText(msg!)
                })
            }
        }
        
        if (self.connection.didFinisTransferFile == nil){
            self.connection.didFinisTransferFile = { (url, metadata) -> Void in
                print("\(url)");
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object === self.connection){
            if (keyPath == kConnectionChange){
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.setTitle(self.connection.state.rawValue)
                })
            }
        }
    }

    @IBAction func didTapSendButton() {
        self.connection.sendMessage(["Message": "Call me apple watch"])
    }

}
