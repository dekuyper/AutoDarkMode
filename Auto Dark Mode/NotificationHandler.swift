//
//  NotificationHelper.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationHandler: AppManagedObject, AppManagerDelegate, UNUserNotificationCenterDelegate {

    let notificationCenter = UNUserNotificationCenter.current()
    
    func scheduleTestNotification() {
        // Content
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]

        // Trigger time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    // Location Handler notifications
    func locationPermissions(denied message: String) {
        print("Location permissions denied.: Message: \(message)")
    }

    func locationPermissions(restricted message: String) {
        print("Location permissions restricted. Message: \(message)")
    }
    
    func locationPermissions(failed message: String) {
        print("App could not access locations. Loation services may be unavailable or are turned off. Error code: \(message)")
    }

    // App Manager delegate calls
    func appDidFinishLaunching(_ manager: AppManager) {
        notificationCenter.requestAuthorization(options: [.alert, .badge])
        { (granted, error) in
            // Enable or disable features based on authorization.
            if granted {
                print("Notifications permission granted.")
                self.scheduleTestNotification()
            } else {
                print("Notifications permission denied.")
            }
        }
    }
    
    func appWillTerminate(_ manager: AppManager) {
        
    }
    
    func registerToDelegateCallers() {
        manager.addDelegate(newElement: self)
        notificationCenter.delegate = self
    }
    
}
