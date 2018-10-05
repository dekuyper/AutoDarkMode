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
    var darkModeHandler = DarkModeHandler()
    var menuHandler = AppMenuDelegate()
    var timerHandler = TimerHandler()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menuHandler.onAppDidFinishLaunching()
        darkModeHandler.onAppDidFinishLaunching()
        timerHandler.onAppDidFinishLaunching()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        menuHandler.onAppWillTerminate()
        darkModeHandler.onAppWillTerminate()
        timerHandler.onAppWillTerminate()
    }

}
