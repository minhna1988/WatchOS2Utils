//
//  DataTransfer.swift
//  WatchKitUtils
//
//  Created by Nguyen Anh Minh on 2/24/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import WatchConnectivity

class DataTransfer: Connection {
    
    enum ResponseCode: String{
        case Error = "Error"
        case Success = "Success"
    }
    
    var didReceiveMessage: ([String : AnyObject]->Void)! = nil
    var didReceiveFile: ((NSURL, [String:AnyObject]?)->Void)! = nil
    var didFinisTransferFile: ((WCSessionFileTransfer, NSError?)->Void)! = nil
    
    
    class var getInstance: DataTransfer{
        struct Static {
            static var token: dispatch_once_t = 0
            static var instance: DataTransfer! = nil
        }
        
        dispatch_once(&Static.token) { () -> Void in
            Static.instance = DataTransfer()
        }
        
        return Static.instance
    }
    
    
    // MARK: Message
    func sendMessage(message: [String : AnyObject]){
        if (!self.session.reachable){
            self.didReceiveMessage([ResponseCode.Error.rawValue: self.state])
            return
        }
        
        self.session.sendMessage(message, replyHandler: nil) { (error) -> Void in
            print("\(error)")
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if (self.didReceiveMessage != nil){
            self.didReceiveMessage(message)
        }
    }
    
    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        if (self.didReceiveMessage != nil){
            self.didReceiveMessage(["Success": messageData])
        }
    }
    
    // MARK: File
    func sendFile(file: NSURL!, metadata: [String:AnyObject]?){
        self.session.transferFile(file, metadata: metadata)
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        if (self.didReceiveFile != nil){
            self.didReceiveFile(file.fileURL, file.metadata)
        }
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        if (self.didFinisTransferFile != nil){
            self.didFinisTransferFile(fileTransfer, error)
        }
    }
}