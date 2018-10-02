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
        
        setCurrentDarkModeState()
        setDarkModeTimers()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setCurrentDarkModeState() {
        
        
    }
    
    func getSunriseDate() -> Date {
        return Date().addingTimeInterval(5)
    }
    
    func getSunsetDate() -> Date {
        return Date().addingTimeInterval(15)
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Enable Dark Mode", action: #selector(AppDelegate.enableDarkMode), keyEquivalent: "D"))
        menu.addItem(NSMenuItem(title: "Disable Dark Mode", action: #selector(AppDelegate.disableDarkMode), keyEquivalent: "d"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func setDarkModeTimers() {
        let sunriseDate = getSunriseDate()
        let sunsetDate = getSunsetDate()
        let sunriseTimer = Timer(fireAt: sunriseDate, interval: 0, target: self, selector: #selector(disableDarkMode), userInfo: nil, repeats: false)
        let sunsetTimer = Timer(fireAt: sunsetDate, interval: 0, target: self, selector: #selector(enableDarkMode), userInfo: nil, repeats: false)

        RunLoop.main.add(sunriseTimer, forMode: RunLoop.Mode.common)
        RunLoop.main.add(sunsetTimer, forMode: RunLoop.Mode.common)
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
