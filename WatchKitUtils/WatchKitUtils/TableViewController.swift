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
        case ChooseFile = 4
    }
    
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    
    var tempDirectory: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
    
    var connection: DataTransfer! = nil
    var watchSize: CGSize = CGSizeMake(272, 340)
    var selectedFile: [String:AnyObject]! = nil
    
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
                    if (msg == "ScreenSize"){
                        self.receivedLabel.text = message["Content"] as! String!
                        self.watchSize = CGSizeFromString(self.receivedLabel.text!)
                    }
                })
            }
        }
        
        if (self.connection.didFinishTransferFile == nil){
            self.connection.didFinishTransferFile = { (file, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.browseButton.enabled = true
                    if (error != nil){
                        self.sendButton .setTitle("Error", forState: UIControlState.Normal)
                    } else {
                        self.sendButton .setTitle("Sent", forState: UIControlState.Normal)
                    }
                })
            }
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
    
    // MARK: Button Event
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
            self.browseButton.enabled = false
            self.sendButton.enabled = false
            self.sendButton .setTitle("Sending...", forState: UIControlState.Normal)
            self.connection.sendFile(NSURL(fileURLWithPath: self.selectedFile!["file"] as! String), metadata: self.selectedFile!["metadata"] as? [String:AnyObject])
            break
        case .SendData:
            break
        case .ChooseFile:
            self.openPhoto(UIImagePickerControllerSourceType.PhotoLibrary)
            break
        }
    }
    
    // MARK: Text Field Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        let type: ActionType = ActionType(rawValue: textField.tag)!
        switch (type){
        case .SendMessage:
            break
        case .SendFile:
            
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
    
    // MARK: UIImagePicker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        var image: UIImage? = info[UIImagePickerControllerOriginalImage] as! UIImage?;
        if (image == nil) {
            return
        }
        switch (picker.sourceType){
        case .PhotoLibrary:
            picker.dismissViewControllerAnimated(true, completion: { () -> Void in
                let urlString = (info["UIImagePickerControllerReferenceURL"] as! NSURL).absoluteString
                let startRange = urlString.rangeOfString("id=")
                let endRange = urlString.rangeOfString("&ext=")
                if (startRange != nil && endRange != nil) {
                    let id = urlString.substringWithRange(Range(start: startRange!.endIndex, end: endRange!.startIndex))
                    let ext = urlString.substringWithRange(Range(start: endRange!.endIndex, end: urlString.endIndex)).lowercaseString
                    let path = self.tempDirectory.stringByAppendingFormat("/%@.%@", id, ext)

                    image = self.resizeImage(image!, targetSize: self.watchSize)
                    
                    let imageData = ext == "jpg" ? UIImageJPEGRepresentation(image!, 1.0) : (ext == "png" ? UIImagePNGRepresentation(image!) : nil)
                    if (imageData == nil){
                        return
                    }
                    let success = imageData!.writeToFile(path, atomically: true)
                    if (!success){
                        return
                    }
                    self.selectedImageView.image = image
                    self.sendButton.enabled = true
                    self.sendButton .setTitle("Send", forState: UIControlState.Normal)
                    self.browseButton .setTitle("", forState: UIControlState.Normal)
                    self.selectedFile = ["file": path, "metadata": ["name":id, "ext":ext]]
                }
            })
            break
        case .Camera:
            var localId: String = ""
            let library: PHPhotoLibrary = PHPhotoLibrary()
            library.performChanges(
                { () -> Void in
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image!)
                    localId = assetChangeRequest.placeholderForCreatedAsset!.localIdentifier
                    print("\(localId)")
                }, completionHandler:
                { (success, error) -> Void in
                    picker.dismissViewControllerAnimated(true, completion: { () -> Void in
                        if (!success){
                            self.showMessage(error!.description)
                            return
                        }
                    })
                }
            )
            break
        default:
            break
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Support Function
    func showMessage(message: String){
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        let alertView: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertView.addAction(cancelAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func getAssetUrl(mPhasset : PHAsset, completionHandler : ((responseURL : NSURL?) -> Void)){
        
        if mPhasset.mediaType == .Image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInputWithOptions(options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [NSObject : AnyObject]) -> Void in
                completionHandler(responseURL : contentEditingInput!.fullSizeImageURL)
            })
        } else if mPhasset.mediaType == .Video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .Original
            PHImageManager.defaultManager().requestAVAssetForVideo(mPhasset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) -> Void in
                
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl : NSURL = urlAsset.URL
                    completionHandler(responseURL : localVideoUrl)
                } else {
                    completionHandler(responseURL : nil)
                }
            })
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
