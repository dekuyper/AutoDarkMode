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
    var darkModeHandler: DarkModeHandler?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("status-bar-icon"))
        }

        constructMenu()
        darkModeHandler = DarkModeHandler()
        darkModeHandler?.startReceivingLocationChanges()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        darkModeHandler?.invalidateTimers()
    }

    func constructMenu() {
        let menu = NSMenu()
        // TODO: Only show one action (Disable if enabled and reverse)
        // TODO: Show status and at what times it changes
        menu.addItem(NSMenuItem(title: "Enable Dark Mode", action: #selector(enableDarkMode), keyEquivalent: "D"))
        menu.addItem(NSMenuItem(title: "Disable Dark Mode", action: #selector(disableDarkMode), keyEquivalent: "d"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }

    func initNotifications() {
        
    }
    
    @objc func enableDarkMode() {
        darkModeHandler?.enableDarkMode()
    }

    @objc func disableDarkMode() {
        darkModeHandler?.disableDarkMode()
    }

}
