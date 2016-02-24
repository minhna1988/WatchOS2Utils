//
//  Connection.swift
//  WatchKitUtils
//
//  Created by Nguyen Anh Minh on 2/23/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import Foundation
import WatchConnectivity

let kConnectionStateDidChange: String = "ConnectionStateDidChange"

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
    
    var state = String(){
        didSet{
            didChangeValueForKey(kConnectionStateDidChange)
        }
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
            self.state = ConnectionState.NotPair.rawValue
            return
        }
        self.state = ConnectionState.Paired.rawValue
        if (!session.watchAppInstalled){
            self.state = ConnectionState.AppNotInstall.rawValue
            return
        }
        self.state = ConnectionState.AppInstalled.rawValue
    }
    #endif
    
    func sessionReachabilityDidChange(session: WCSession) {
        self.state = session.reachable ? ConnectionState.Reachable.rawValue : ConnectionState.UnReachable.rawValue
    }
    
}