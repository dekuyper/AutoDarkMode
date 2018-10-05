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

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        appManager.appDidFinishLaunching()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
        appManager.appWillTerminate()
        
    }

}
