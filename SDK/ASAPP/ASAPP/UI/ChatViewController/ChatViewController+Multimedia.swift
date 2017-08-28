//
//  ChatViewController+Multimedia.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

import AVFoundation

extension ChatViewController {
    
    func presentImageUploadOptions(fromView presentFromView: UIView) {
        let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        let photoLibraryIsAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        
        if !cameraIsAvailable && !photoLibraryIsAvailable {
            // Show alert to check settings
            showAlert(title: ASAPPLocalizedString("Photos Unavailable"),
                      message: ASAPPLocalizedString("Please check your device's support for multimedia."))
            return
        }
        
        if cameraIsAvailable && photoLibraryIsAvailable {
            presentCameraOrPhotoLibrarySelection(fromView: presentFromView)
        } else if cameraIsAvailable {
            presentCamera()
        } else if photoLibraryIsAvailable {
            presentPhotoLibrary()
        }
    }
    
    func presentCameraOrPhotoLibrarySelection(fromView presentFromView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Camera"), style: .default, handler: { [weak self] (alert) in
            self?.presentCameraIfAuthorized()
        }))
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Photo Library"), style: .default, handler: { [weak self] (alert) in
            self?.presentPhotoLibrary()
        }))
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Cancel"), style: .destructive, handler: { (alert) in
            // No-op
        }))
        alertController.popoverPresentationController?.sourceView = presentFromView
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentCameraIfAuthorized() {
        CameraPermsissions.isAuthorized { [weak self] (authorized) in
            Dispatcher.performOnMainThread {
                if authorized {
                    self?.presentCamera()
                } else {
                    
                    
                    
                    self?.showCameraNotAuthorizedAlert()
                }
            }
        }
    }
    
    func showCameraNotAuthorizedAlert() {
        let alert = UIAlertController(title: ASAPP.strings.cameraPermissionsErrorTitle,
                                      message: ASAPP.strings.cameraPermissionsErrorMessage,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: ASAPP.strings.cameraPermissionsErrorCancelButton,
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: ASAPP.strings.cameraPermissionsErrorSettingsButton,
                                      style: .default,
                                      handler: { (action) in
                                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                                            UIApplication.shared.openURL(settingsURL)
                                        }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let imagePickerController = createImagePickerController(withSourceType: .camera)
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func presentPhotoLibrary() {
        let imagePickerController = createImagePickerController(withSourceType: .photoLibrary)
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func createImagePickerController(withSourceType sourceType: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        
        let barTintColor = ASAPP.styles.colors.navBarBackground
        imagePickerController.navigationBar.shadowImage = nil
        imagePickerController.navigationBar.setBackgroundImage(nil, for: .default)
        imagePickerController.navigationBar.barTintColor = barTintColor
        imagePickerController.navigationBar.tintColor = ASAPP.styles.colors.navBarButton
        if barTintColor.isBright() {
            imagePickerController.navigationBar.barStyle = .default
        } else {
            imagePickerController.navigationBar.barStyle = .black
        }
        imagePickerController.view.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        return imagePickerController
    }
}


class CameraPermsissions {
    
    class func isAuthorized(_ completion: @escaping (Bool) -> ()) {
        let mediaType = AVMediaTypeVideo
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .denied, .restricted:
            DebugLog.d(caller: ChatViewController.self, "Camera Permissions: Denied or Restricted")
            completion(false)
            break
            
        case .authorized:
            DebugLog.d(caller: ChatViewController.self, "Camera Permissions: Authorized")
            completion(true)
            break
            
        case .notDetermined:
            // Request permission from the user
            AVCaptureDevice.requestAccess(forMediaType: mediaType) { granted in
                DebugLog.d(caller: ChatViewController.self, "Camera Permissions \(granted ? "Granted" : "Denied")!")
                completion(granted)
            }
        }
    }
    
}