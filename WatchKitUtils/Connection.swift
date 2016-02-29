//
//  Connection.swift
//  WatchKitUtils
//
//  Created by Nguyen Anh Minh on 2/23/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import Foundation
import WatchConnectivity

let kConnectionChange: String = "state"

class Connection: NSObject, WCSessionDelegate {
    
    enum ConnectionState: String{
        case NotPair = "Device is not pair"
        case Paired  = "Device is paired"
        case AppNotInstall = "Application is not installed on watch"
        case AppInstalled  = "Application is installed on watch"
        case Reachable   = "Device is reached"
        case UnReachable = "Device is unreached"
    }
    
    var session: WCSession! = nil
    
    var state: ConnectionState! = ConnectionState(rawValue: "Device is not pair"){
        willSet{
            willChangeValueForKey(kConnectionChange)
        }
        didSet{
            didChangeValueForKey(kConnectionChange)
        }
    }
    
    override init() {
        super.init()
    }
    
    func connect(){
        if (WCSession.isSupported()){
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
        #if os(iOS)
            self.sessionWatchStateDidChange(self.session)
        #endif
    }
    
    // MARK: WCSession Delegate
    #if os(iOS)
    func sessionWatchStateDidChange(session: WCSession) {
        if (!session.paired){
            self.state = ConnectionState.NotPair
            return
        }
    
        if (!session.watchAppInstalled){
            self.state = ConnectionState.AppNotInstall
            return
        }
    
        if (!session.reachable){
            self.state = ConnectionState.AppInstalled
            return
        }
    }
    #endif
    
    // This function only call when the user open watch app
    func sessionReachabilityDidChange(session: WCSession) {
        self.state = session.reachable ? ConnectionState.Reachable : ConnectionState.UnReachable
    }
    
}