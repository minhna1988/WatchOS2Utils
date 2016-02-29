//
//  TableViewController.swift
//  WatchKitUtils
//
//  Created by Nguyen Anh Minh on 2/24/16.
//  Copyright © 2016 Minh Nguyen. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class TableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
        
        if (self.connection.didReceiveMessage == nil){
            self.connection.didReceiveMessage = { (message) -> Void in
                let msg = message["Message"] as! String?
                if (msg == nil){
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.receivedLabel.text = msg!
                })
            }
        }
        
        if (self.connection.didFinisTransferFile == nil){
            self.connection.didFinisTransferFile = { (url, metadata) -> Void in
                print("\(url)");
            }
        }
    }
    
    @IBAction func didTapSendButton(sender: UIButton) {
        let type: ActionType = ActionType(rawValue: sender.tag)!
        switch (type){
        case .SendMessage:
            if (self.messageTextField.text == nil){
                return
            }
            self.connection.sendMessage(["Message": messageTextField.text!])
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
    
    // MARK: Text Field Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        let type: ActionType = ActionType(rawValue: textField.tag)!
        switch (type){
        case .SendMessage:
            break
        case .SendFile:
            self.openPhoto(UIImagePickerControllerSourceType.PhotoLibrary)
            break;
        default:
            break
        }
    }
    
    // MARK: Working with Photos and Camera
    func openPhoto(sourceType: UIImagePickerControllerSourceType){
        
        if (!self.checkPermission(sourceType)){
            return
        }
        
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false;
        picker.sourceType = sourceType;
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func checkPermission(sourceType: UIImagePickerControllerSourceType)->Bool{
        switch (sourceType){
        case UIImagePickerControllerSourceType.PhotoLibrary:
            let permission: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            if (permission == PHAuthorizationStatus.Restricted || permission == PHAuthorizationStatus.Denied){
                self.showMessage("Open settings to allow app access Photos")
                return false
            }
            return true
        case UIImagePickerControllerSourceType.Camera:
            let permission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            if (permission == AVAuthorizationStatus.Restricted || permission == AVAuthorizationStatus.Denied){
                self.showMessage("Open settings to allow app access Camera")
                return false
            }
            return true
        default:
            return false
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if (editingInfo == nil){
            return
        }
        
        let image: UIImage? = editingInfo![UIImagePickerControllerOriginalImage] as! UIImage?;
        if (image == nil) {
            return
        }
        
        switch (picker.sourceType){
        case .PhotoLibrary:
            break
        case .Camera:
            var localId: String = ""
            let library: PHPhotoLibrary = PHPhotoLibrary()
            library.performChanges({ () -> Void in
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image!)
                localId = assetChangeRequest.placeholderForCreatedAsset!.localIdentifier
                }, completionHandler: { (success, error) -> Void in
                    if (!success){
                        self.showMessage(error!.description)
                        return
                    }
            })
            break
        default:
            break
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showMessage(message: String){
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        let alertView: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertView.addAction(cancelAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}
