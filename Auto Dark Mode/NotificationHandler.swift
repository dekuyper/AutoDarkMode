//
//  NotificationHelper.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation

class NotificationHandler: NSObject, NSUserNotificationCenterDelegate {
    
    func showAlert(title: String, message: String) {
        print(
            "Title: \(title)",
            "Message: \(message)"
        )
    }
    
    func showDeniedAlert() {
        print("Location access denied")
    }

}
