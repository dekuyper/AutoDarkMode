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
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var darkModeHandler = DarkModeHandler()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("status-bar-icon"))
        }

        constructMenu()
        darkModeHandler.onAppFinishedLoading()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        darkModeHandler.onAppWillTerminate()
    }

    func constructMenu() {
        let menu = NSMenu()

        let statusMenuItem = getStatusMenuItem()
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem(title: "Enable Dark Mode", action: #selector(enableDarkMode), keyEquivalent: "D"))
        menu.addItem(NSMenuItem(title: "Disable Dark Mode", action: #selector(disableDarkMode), keyEquivalent: "d"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func getStatusMenuItem() -> NSMenuItem {
        let nextChange = getNextRunningTimerString()
        let nextStatus = DarkMode.isEnabled ? "Disabled" : "Enabled"
        let title = "Dark Mode will be \(nextStatus) at \(nextChange)"
        return NSMenuItem(title: title, action: nil, keyEquivalent: "")
    }
    
    func getNextRunningTimerString() -> String {
        guard let nextTimer = darkModeHandler.getNextRunningTimer() else { return "[Not Determined]"}
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatterPrint.string(from: nextTimer.fireDate)
    }
    
    @objc func enableDarkMode() {
        darkModeHandler.enableDarkMode()
    }

    @objc func disableDarkMode() {
        darkModeHandler.disableDarkMode()
    }

}
