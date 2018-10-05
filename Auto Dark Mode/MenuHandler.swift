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
    var timer: TimerHandler
    var darkMode: DarkModeHandler

    init(title: String, timerHandler: TimerHandler, darkModeHandler: DarkModeHandler) {
        timer = timerHandler
        darkMode = darkModeHandler

        super.init(title: title)

        constructMenu()
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructMenu() {
        appName()
        separator()
        nextEventTextItem()
        statusTextItem()
        separator()
        toggleItem()
        separator()
        quitItem()
    }

    func appName() {
        addItem(NSMenuItem(title: "Auto Dark Mode", action: nil, keyEquivalent: ""))
    }
    
    func statusTextItem() {
        let currentStatus = DarkMode.isEnabled ? "Enabled" : "Disabled"
        let statusText = "Dark Mode is \(currentStatus)"
        let menuItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        menuItem.tag = 2

        addItem(menuItem)
    }

    func nextEventTextItem() {
        let title = nextEventTitle()
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.tag = 3
        
        addItem(menuItem)
    }

    func nextEventTitle() -> String{
        let nextChange = getNextRunningTimerString()
        let nextStatus = DarkMode.isEnabled ? "Disabled" : "Enabled"
        return "Dark Mode will be \(nextStatus) at \(nextChange)"
    }

    func toggleItem() {
        let toggleItem = NSMenuItem(title: "Toggle Dark Mode", action: #selector(toggleDarkMode), keyEquivalent: "T")
        toggleItem.tag = 4
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
        guard let nextTimer = timer.nextRunningTimer else { return "--:--"}
        print(nextTimer.fireDate)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatterPrint.string(from: nextTimer.fireDate)
    }
    
    @objc func toggleDarkMode() {
        darkMode.toggle()
    }

}

class MenuHandler: AppManagedObject, AppManagerDelegate, TimerHandlerDelegate, NSMenuDelegate {

    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()
    
    var menu: AppMenu?
    var timerHandler: TimerHandler {
        get {
            return (manager.container?.TimerHandler)!
        }
    }
    var darkModeHandler: DarkModeHandler {
        get {
            return (manager.container?.DarkModeHandler)!
        }
    }
    
    // DELEGATE CALLS
    func timerHandler(didFinishLoading timerHandler: TimerHandler) {
        print("TimerHandlerDelegate Fires")
        updateNextEventTextItem()
    }
    
    func updateNextEventTextItem() {
        let menuItem = menu!.item(withTag: 3)
        menuItem!.title = (menu?.nextEventTitle())!
    }

    func appDidFinishLaunching(_ manager: AppManager) {
        menu = AppMenu(
            title: "Auto Dark Mode",
            timerHandler: timerHandler,
            darkModeHandler: darkModeHandler
        )

        statusItem.button!.image = NSImage(named:NSImage.Name("status-bar-icon"))
        statusItem.isVisible = true
        statusItem.menu = menu
    }
    
    
    func appWillTerminate(_ manager: AppManager) {
        
    }

    func registerToDelegateCallers() {
        manager.addDelegate(newElement: self)
        timerHandler.addDelegate(newElement: self)
    }
    
}
