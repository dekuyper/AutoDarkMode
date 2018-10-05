//
//  NotificationHelper.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation

class NotificationHandler: AppManagedObject, AppManagerDelegate, NSUserNotificationCenterDelegate {
    
    func showAlert(title: String, message: String) {
        print(
            "Title: \(title)",
            "Message: \(message)"
        )
    }
    
    func showDeniedAlert() {
        print("Location access denied")
    }
    
    // App Manager delegate calls
    func appDidFinishLaunching(_ manager: AppManager) {
        
    }
    
    func appWillTerminate(_ manager: AppManager) {
        
    }
    
    func addManagerDelegate() {
        manager.addDelegate(newElement: self)
    }
    
}
