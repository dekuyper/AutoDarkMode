//
//  MenuHandler.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 04/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import AppKit


class AppMenu: NSMenu {
    var timerHandler: TimerHandler

    init(title: String, handler: TimerHandler) {
        timerHandler = handler

        super.init(title: title)

        constructMenu()
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructMenu() {
        nextEventTextItem()
        statusTextItem()
        separator()
        toggleItem()
        separator()
        quitItem()
    }

    func statusTextItem() {
        let currentStatus = DarkMode.isEnabled ? "Enabled" : "Disabled"
        let statusText = "Dark Mode is \(currentStatus)"
        
        addItem(NSMenuItem(title: statusText, action: nil, keyEquivalent: ""))
    }

    func nextEventTextItem() {
        let nextChange = getNextRunningTimerString()
        let nextStatus = DarkMode.isEnabled ? "Disabled" : "Enabled"
        let title = "Dark Mode will be \(nextStatus) at \(nextChange)"

        addItem(NSMenuItem(title: title, action: nil, keyEquivalent: ""))
    }

    func toggleItem() {
        let toggleItem = NSMenuItem(title: "Toggle Dark Mode", action: #selector(toggleDarkMode), keyEquivalent: "T")
        toggleItem.isEnabled = true
        toggleItem.target = self
        
        addItem(toggleItem)
    }
    
    func separator() {
        addItem(NSMenuItem.separator())
    }

    func quitItem() {
        addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    func getNextRunningTimerString() -> String {
        guard let nextTimer = timerHandler.getNextRunningTimer() else { return "--:--"}
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatterPrint.string(from: nextTimer.fireDate)
    }
    
    @objc func toggleDarkMode() {
        _ = DarkMode.toggle()
    }

}

class MenuHandler: AppManagedObject, AppManagerDelegate, NSMenuDelegate {
    
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()

    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        return true
    }

    func appDidFinishLaunching(_ manager: AppManager) {
        let menu = AppMenu(title: "Auto Dark Mode", handler: (manager.container?.TimerHandler)!)
        statusItem.button!.image = NSImage(named:NSImage.Name("status-bar-icon"))
        statusItem.isVisible = true
        statusItem.menu = menu
    }
    
    func appWillTerminate(_ manager: AppManager) {
        
    }

    func registerToDelegateCallers() {
        manager.addDelegate(newElement: self)
    }
    
}
