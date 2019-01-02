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
    
    var statusTitle: String {
        get {
            let currentStatus = DarkMode.isEnabled ? "Enabled" : "Disabled"
            
            return "Current status:  \(currentStatus)"
        }
    }
    
    var toggleTitle: String {
        get {
            let nextAction = DarkMode.isEnabled ? "Disable" : "Enable"
            
            return "\(nextAction) Dark Mode"
        }
    }
    
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
        addAppName()
        separator()
        addCurrentStatus()
        addNextEventItem()
        separator()
        addToggleItem()
        separator()
        addQuitItem()
    }

    func addAppName() {
        addItem(NSMenuItem(title: "Auto Dark Mode", action: nil, keyEquivalent: ""))
    }
    
    func addCurrentStatus() {
        let menuItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        menuItem.tag = 2

        addItem(menuItem)
    }
    
    func addNextEventItem() {
        let title = nextEventTitle()
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.tag = 3
        
        addItem(menuItem)
    }

    func nextEventTitle() -> String {
        let nextChange = getNextRunningTimer()
        let nextStatus = DarkMode.isEnabled ? "Disabled" : "Enabled"
        return "Dark Mode will be \(nextStatus) at \(nextChange)"
    }

    func addToggleItem() {
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleDarkMode), keyEquivalent: "T")
        toggleItem.tag = 4
        toggleItem.isEnabled = true
        toggleItem.target = self
        
        addItem(toggleItem)
    }
    
    func separator() {
        addItem(NSMenuItem.separator())
    }

    func addQuitItem() {
        addItem(NSMenuItem(title: "Quit Auto Dark Mode", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    func getNextRunningTimer() -> String {
        guard let nextTimer = timer.nextRunningTimer else { return "--:--"}

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatterPrint.string(from: nextTimer.fireDate)
    }
    
    @objc func toggleDarkMode() {
        darkMode.toggle()
    }

}

class MenuHandler: AppManagedObject,
                   AppManagerDelegate,
                   TimerHandlerDelegate,
                   DarkModeHandlerDelegate,
                   NSMenuDelegate
{

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

    func updateNextEventTextItem() {
        let menuItem = menu!.item(withTag: 3)
        menuItem!.title = (menu?.nextEventTitle())!
    }
    
    func updateStatusTextItem() {
        let menuItem = menu!.item(withTag: 2)
        menuItem?.title = (menu?.statusTitle)!
    }
    
    func updateToggleItem() {
        let menuItem = menu!.item(withTag: 4)
        menuItem?.title = (menu?.toggleTitle)!
    }

    // DELEGATE CALLS
    func timerHandler(didFinishLoading timerHandler: TimerHandler) {
        updateNextEventTextItem()
    }
    
    func darkModeHandler(didToggleDarkMode newValue: Bool) {
        updateStatusTextItem()
        updateToggleItem()
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
        darkModeHandler.addDelegate(newElement: self)
    }
    
}
