//
//  MenuHandler.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 04/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import Solar
import CoreLocation

class MenuHandler: NSObject, NSMenuDelegate {
    
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()
    let timerHandler = TimerHandler()

    func onAppDidFinishLaunching() {
        statusItem.button!.image = NSImage(named:NSImage.Name("status-bar-icon"))
        statusItem.isVisible = true

        
        constructMenu(statusItem: statusItem)
    }
    
    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        return true
    }
    
    func constructMenu(statusItem: NSStatusItem) {
        
        let menu = NSMenu(title: "Auto Dark Mode")
        
        let nextEventText = NSMenuItem(title: getStatusText(), action: nil, keyEquivalent: "")
        let currentStatus = DarkMode.isEnabled ? "Enabled" : "Disabled"
        let statusText = "Dark Mode is \(currentStatus)"
        let toggleItem = NSMenuItem(title: "Toggle Dark Mode", action: #selector(toggleDarkMode), keyEquivalent: "T")
        toggleItem.isEnabled = true
        toggleItem.target = self
        menu.addItem(nextEventText)
        menu.addItem(NSMenuItem(title: statusText, action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(toggleItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func getStatusText() -> String {
        let nextChange = getNextRunningTimerString()
        let nextStatus = DarkMode.isEnabled ? "Disabled" : "Enabled"
        let title = "Dark Mode will be \(nextStatus) at \(nextChange)"
        return title
    }
    
    func getNextRunningTimerString() -> String {
        guard let nextTimer = timerHandler.getNextRunningTimer() else { return "--:--"}
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatterPrint.string(from: nextTimer.fireDate)
    }
    
    func onAppWillTerminate() {

    }
    
    @objc func toggleDarkMode() {
        _ = DarkMode.toggle()
    }
}
