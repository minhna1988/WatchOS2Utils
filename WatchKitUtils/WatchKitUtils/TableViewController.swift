//
//  TableViewController.swift
//  WatchKitUtils
//
//  Created by Nguyen Anh Minh on 2/24/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    
    var connection: DataTransfer! = DataTransfer.getInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connection.addObserver(self, forKeyPath: kConnectionStateDidChange, options: NSKeyValueObservingOptions(), context: nil)
    }
    
    @IBAction func didTapSendButton(sender: UIButton) {
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object === self.connection){
            if (keyPath == kConnectionStateDidChange){
                print("\(change)")
                //self.connectionStateLabel.text =
            }
        }
    }
}
