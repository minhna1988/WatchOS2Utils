//
//  TableViewController.swift
//  WatchKitUtils
//
//  Created by Nguyen Anh Minh on 2/24/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITextFieldDelegate {
    
    enum ActionType: Int {
        case SendMessage = 1
        case SendFile = 2
        case SendData = 3
    }
    
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var browseFileTextField: UITextField!
    
    var connection: DataTransfer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connection = DataTransfer.getInstance
        self.connection.addObserver(self, forKeyPath: kConnectionChange, options: NSKeyValueObservingOptions(), context: nil)
        self.connection.connect()
    }
    
    @IBAction func didTapSendButton(sender: UIButton) {
        let type: ActionType = ActionType(rawValue: sender.tag)!
        switch (type){
            case .SendMessage:
                break
            case .SendFile:
                break
            case .SendData:
                break
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object === self.connection){
            if (keyPath == kConnectionChange){
                print("\(self.connection.state.rawValue)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.connectionStateLabel.text = self.connection.state.rawValue
                })
            }
        }
    }
}
