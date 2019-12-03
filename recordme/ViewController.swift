//
//  ViewController.swift
//  recordme
//
//  Created by 林暐秦 on 2019/12/3.
//  Copyright © 2019 imappUITests. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {

    // Broadcast state. Our extension will capture samples from ReplayKit, and publish them in a Room.
    var broadcastController: RPBroadcastController?
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var broadcastButton: UIButton!
    @IBOutlet weak var conferenceButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    static let kBroadcastExtensionBundleId = "com.tomas.recordme.broadcast"
    
    static let kBroadcastExtensionSetupUiBundleId = "com.tomas.recordme.broadcastSetupUI"
    static let kStartBroadcastButtonTitle = "Start Broadcast"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 12.0, *) {
            setupPickerView()
        }
    }

     @available(iOS 12.0, *)
    func setupPickerView() {
        // Swap the button for an RPSystemBroadcastPickerView.
        #if !targetEnvironment(simulator)
        // iOS 13.0 throws an NSInvalidArgumentException when RPSystemBroadcastPickerView is used to start a broadcast.
        // https://stackoverflow.com/questions/57163212/get-nsinvalidargumentexception-when-trying-to-present-rpsystembroadcastpickervie
        if #available(iOS 13.0, *) {
            // The issue is resolved in iOS 13.1.
//            if #available(iOS 13.1, *) {
//                print("iOS 13.1, *")
//            } else {
//                print("iOS 13.1, * else")
                broadcastButton.addTarget(self, action: #selector(tapBroadcastPickeriOS13(sender:)), for: UIControl.Event.touchUpInside)
//                return
//            }
        }

        let pickerView = RPSystemBroadcastPickerView(frame: CGRect(x: 0,
                                                                   y: 0,
                                                                   width: view.bounds.width,
                                                                   height: 80))
        
        pickerView.showsMicrophoneButton = false
        // Theme the picker view to match the white that we want.
//        if let button = pickerView.subviews.first as? UIButton {
//            button.imageView?.tintColor = UIColor.white
//        }
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.preferredExtension = ViewController.kBroadcastExtensionBundleId
        view.addSubview(pickerView)

//        self.broadcastPickerView = pickerView
//        broadcastButton.isEnabled = false
//        broadcastButton.titleEdgeInsets = UIEdgeInsets(top: 34, left: 0, bottom: 0, right: 0)

        let centerX = NSLayoutConstraint(item:pickerView,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: broadcastButton,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: pickerView,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: broadcastButton,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1,
                                         constant: -10);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: pickerView,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: self.broadcastButton,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: pickerView,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: self.broadcastButton,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
        #endif
    }
    
    @IBAction func startBroadcast(_ sender: Any) {
//        if let controller = self.broadcastController {
//            controller.finishBroadcast { [unowned self] error in
//                DispatchQueue.main.async {
//                    self.spinner.stopAnimating()
//                    self.broadcastController = nil
//                    self.broadcastButton.setTitle(ViewController.kStartBroadcastButtonTitle, for: .normal)
//                }
//            }
//        } else {
//            // This extension should be the broadcast upload extension UI, not broadcast update extension
//            RPBroadcastActivityViewController.load(withPreferredExtension:ViewController.kBroadcastExtensionSetupUiBundleId) {
//                (broadcastActivityViewController, error) in
//                if let broadcastActivityViewController = broadcastActivityViewController {
//                    broadcastActivityViewController.delegate = self
//                    broadcastActivityViewController.modalPresentationStyle = .popover
//                    self.present(broadcastActivityViewController, animated: true)
//                }
//            }
//        }
    }

    @objc func tapBroadcastPickeriOS13(sender: UIButton) {
        let message = "ReplayKit broadcasts can not be started using the broadcast picker on iOS 13.0. Please upgrade to iOS 13.1+, or start a broadcast from the screen recording widget in control center instead."
        let alertController = UIAlertController(title: "Start Broadcast", message: message, preferredStyle: .actionSheet)

        let settingsButton = UIAlertAction(title: "Launch Settings App", style: .default, handler: { (action) -> Void in
            // Launch the settings app, with control center if possible.
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { (success) in
            }
        })

        alertController.addAction(settingsButton)

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sender
            alertController.popoverPresentationController?.sourceRect = sender.bounds
        } else {
            // Adding the cancel action
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            })
            alertController.addAction(cancelButton)
        }
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
}

// MARK:- RPBroadcastActivityViewControllerDelegate
extension ViewController: RPBroadcastActivityViewControllerDelegate {
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        DispatchQueue.main.async {
            self.broadcastController = broadcastController
            self.broadcastController?.delegate = self as! RPBroadcastControllerDelegate
            self.conferenceButton?.isEnabled = false
            self.infoLabel?.text = ""

            broadcastActivityViewController.dismiss(animated: true) {
                self.startBroadcast(self)
            }
        }
    }
}
