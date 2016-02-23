//
//  Connection.swift
//  WatchKitUtils
//
//  Created by Nguyen Anh Minh on 2/23/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import Foundation
import WatchConnectivity

class Connection: NSObject, WCSessionDelegate {
    
    var session: WCSession! = nil
    
    class var getInstance: Connection{
        struct Static {
            static var token: dispatch_once_t = 0
            static var instance: Connection! = nil
        }
        
        dispatch_once(&Static.token) { () -> Void in
            Static.instance = Connection()
        }
        
        return Static.instance
    }
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()){
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
        
    }
    
    // MARK: WCSession Delegate
    #if os(iOS)
    func sessionWatchStateDidChange(session: WCSession) {
        if (!session.paired){
            print("Not pair")
            return
        }
        
        if (!session.watchAppInstalled){
            print("Not install")
            return
        }
    }
    #endif
    
    func sessionReachabilityDidChange(session: WCSession) {
        let status = session.reachable ? "Reachable" : "UnReachable"
        print("sessionReachabilityDidChange is \(status)")
    }
    
    // MARK: WSession Receive message
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
    }
    
    // MARK: WSession Receive message with data
    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        
    }
    
    
}