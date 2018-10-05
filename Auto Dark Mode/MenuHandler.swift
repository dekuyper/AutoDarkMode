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


class AppMenu: NSMenu {
    let timerHandler = TimerHandler()

    override init(title: String) {
        super.init(title: title)
        constructMenu()
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructMenu() {
        constructNextEventTextItem()
        constructStatusTextItem()
        addItem(NSMenuItem.separator())
        constructToggleItem()
        addItem(NSMenuItem.separator())
        addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    func constructStatusTextItem() {
        let currentStatus = DarkMode.isEnabled ? "Enabled" : "Disabled"
        let statusText = "Dark Mode is \(currentStatus)"
        
        addItem(NSMenuItem(title: statusText, action: nil, keyEquivalent: ""))
    }

    func constructNextEventTextItem() {
        let nextChange = getNextRunningTimerString()
        let nextStatus = DarkMode.isEnabled ? "Disabled" : "Enabled"
        let title = "Dark Mode will be \(nextStatus) at \(nextChange)"

        addItem(NSMenuItem(title: title, action: nil, keyEquivalent: ""))
    }

    func constructToggleItem() {
        let toggleItem = NSMenuItem(title: "Toggle Dark Mode", action: #selector(toggleDarkMode), keyEquivalent: "T")
        toggleItem.isEnabled = true
        toggleItem.target = self
        
        addItem(toggleItem)
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

class AppMenuDelegate: NSObject, NSMenuDelegate {

    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()

    let menu = AppMenu()

    func onAppDidFinishLaunching() {
        statusItem.button!.image = NSImage(named:NSImage.Name("status-bar-icon"))
        statusItem.isVisible = true
        statusItem.menu = menu
    }

    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        return true
    }

    func onAppWillTerminate() {

    }
}
