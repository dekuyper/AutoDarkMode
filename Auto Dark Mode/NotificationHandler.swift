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

    let categoryId = "DARK_MODE_SWITCH"
    let notificationCenter = UNUserNotificationCenter.current()
    
    func scheduleNotification() {
        // Content
        let content = UNMutableNotificationContent()
        content.title = "Auto Dark Mode"
        content.body = "Dark Mode will be Disabled in 15 seconds."
        content.categoryIdentifier = categoryId
        content.userInfo = ["SWITCH_TO": "Disable"]

        // Trigger time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

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

    // Config notification center
    func declareNotificationTypes() {
        // Define the custom actions.
        let cancelAction = UNNotificationAction(identifier: "CANCEL_ACTION",
                                                 title: "Cancel",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        // Define the notification type
        let darkModeSwitchCategory =
            UNNotificationCategory(identifier: categoryId,
                                   actions: [cancelAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: .customDismissAction)
        // Register the notification type.
        notificationCenter.setNotificationCategories([darkModeSwitchCategory])
    }
    
    // App Manager delegate calls
    func appDidFinishLaunching(_ manager: AppManager) {
        notificationCenter.requestAuthorization(options: [.alert, .badge])
        { (granted, error) in
            // Enable or disable features based on authorization.
            if granted {
                print("Notifications permission granted.")
                //self.declareNotificationTypes()
                self.scheduleNotification()
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
