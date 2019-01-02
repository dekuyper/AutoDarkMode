//
//  AppDelegate.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 02/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let appManager = AppManager()
    //TODO: - Add context in events and use it to determine the next action
    //      - Delegate calls for new events added to update the menu
    //      - Subscribe to DarmModeHandler.didToggle() with TimerHandler to add the next event
    //      - Register Timers to alert the user before the switching happens
    //      - Add app to login (start-up)

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        appManager.appDidFinishLaunching()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
        appManager.appWillTerminate()
        
    }

}
