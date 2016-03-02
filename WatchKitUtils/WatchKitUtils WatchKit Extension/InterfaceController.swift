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
    var tempDirectory: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
    
    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var sendButton: WKInterfaceButton!
    @IBOutlet var mainGroup: WKInterfaceGroup!

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
        
        if (self.connection.didFinishTransferFile == nil){
            self.connection.didFinishTransferFile = { (file, error) -> Void in
                
            }
        }
        
        if (self.connection.didReceiveFile == nil){
            self.connection.didReceiveFile = { (url, metadata) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("\(url)\n")
                    print("\(metadata)\n")
                    let data = NSData(contentsOfURL: url)
                    if (data == nil){
                        return
                    }
                    
                    var image = UIImage(data: data!)
                    if (metadata != nil){
                        let ext = metadata!["ext"] as! String
                        let name = metadata!["name"] as! String
                        let path = self.tempDirectory.stringByAppendingFormat("/%@.%@", name, ext)
                        let success = data!.writeToFile(path, atomically: true)
                        image = success ? UIImage(contentsOfFile: path) : UIImage(data: data!)
                        self.messageLabel.setText(name)
                    }
                    
                    self.mainGroup.setBackgroundImage(image);
                })
            }
        }
    }
    
    func replyForScreenSize(){
        let currentDevice = WKInterfaceDevice.currentDevice()
        let bounds = currentDevice.screenBounds
        let scale = currentDevice.screenScale
        let size = NSStringFromCGSize(CGSizeMake(bounds.size.width*scale, bounds.size.height*scale))
        self.connection.sendMessage(["Message": "ScreenSize", "Content": size])
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
    
    func showAlert(message: String!){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let cancelAction = WKAlertAction(title: "OK", style: WKAlertActionStyle.Cancel, handler: {() -> Void in
            })
            
            self.presentAlertControllerWithTitle(nil, message: message, preferredStyle: WKAlertControllerStyle.Alert, actions: [cancelAction])
        }
    }

}
