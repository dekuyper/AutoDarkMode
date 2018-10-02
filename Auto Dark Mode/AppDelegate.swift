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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("status-bar-icon"))
        }

        constructMenu()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setTimeTablesFromLocation() {
        // When there are no sub timetables in DB:
            // Get location
            // Get sun timetables for this location
            // Persist timetables
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Enable DarkMode", action: #selector(AppDelegate.enableDarkMode), keyEquivalent: "D"))
        menu.addItem(NSMenuItem(title: "Disable DarkMode", action: #selector(AppDelegate.disableDarkMode), keyEquivalent: "d"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Auto-DarkMode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func enableDarkMode() {
        if DarkMode.isEnabled {
            print("Dark mode already enabled")
            return
        }
        if DarkMode.toggle() {
            print("Enabled DarkMode")
        }
    }
    
    @objc func disableDarkMode() {
        if !DarkMode.isEnabled {
            print("Dark mode already disabled")
            return
        }
        if DarkMode.toggle() {
            print("Disabled Dark Mode")
        }
    }
}
