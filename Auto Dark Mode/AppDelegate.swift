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
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        darkModeHandler?.invalidateTimers()
    }

    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Enable Dark Mode", action: #selector(DarkModeHandler.enableDarkMode), keyEquivalent: "D"))
        menu.addItem(NSMenuItem(title: "Disable Dark Mode", action: #selector(DarkModeHandler.disableDarkMode), keyEquivalent: "d"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
}
