//
//  DarkModeHandler
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 02/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import CoreLocation

struct DarkMode {
    private static let command = "tell application id \"com.apple.systemevents\" to tell appearance preferences to set dark mode to "
    
    static var isEnabled: Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
    
    static var isDisabled: Bool {
        return !isEnabled
    }
    
    static func enable() -> Bool {
        if isEnabled {
            print("Dark mode already enabled")
            return false
        }

        return DarkMode.toggle()
    }
    
    static func disable() -> Bool {
        if isDisabled {
            print("Dark mode already disabled")
            return false
        }

        return DarkMode.toggle()
    }

    static func toggle() -> Bool {
        return runScript(action: !isEnabled)
    }
    
    static func toggle(withForce action: Bool) -> Bool {
        return runScript(action: action)
    }
    
    private static func runScript(action: Bool) -> Bool {
        let script = command + String(action)

        do {
            _ = try AppleScript.run(myAppleScript: script)
        } catch {
            print("Could not toggle Dark mode because AppleScript returned an error.")
            return false
        }
        
        return true
    }

}

class DarkModeHandler: AppManagedObject, AppManagerDelegate, SolarHandlerDelegate {

    var solarHandler: SolarHandler {
        get {
            return (manager.container?.SolarHandler)!
        }
    }

    var delegates: [DarkModeHandlerDelegate] = [DarkModeHandlerDelegate]()

    func addDelegate(newElement: DarkModeHandlerDelegate) {
        delegates.append(newElement)
    }

    func setDarkModeState(isDaytime: Bool) {
        switch isDaytime {
        case true:
            disable()
        case false:
            enable()
        }
    }

    func enable() {
        if DarkMode.enable() {
            didToggle()
        }
    }

    func disable() {
        if DarkMode.disable() {
            didToggle()
        }
    }
    
    func toggle() {
        if DarkMode.toggle() {
            didToggle()
        }
    }
    
    func enableWithAlert(seconds beforeChange: Int) {
        
    }

    // DELEGATE METHODS
    // OWN
    func didToggle() {
        let newValue = DarkMode.isEnabled
        
        delegates.forEach({delegate in
            delegate.darkModeHandler(didToggleDarkMode: newValue)
        })
        
    }
    
    // CALLED
    func registerToDelegateCallers() {
        manager.addDelegate(newElement: self)
        solarHandler.addDelegate(newElement: self)
    }
    
    func appDidFinishLaunching(_ manager: AppManager) {
        
    }
    
    func appWillTerminate(_ manager: AppManager) {
        
    }

    func solarHandler(didFinishLoading solarHandler: SolarHandler) {
        
        setDarkModeState(isDaytime: solarHandler.isDaytime)
        
    }
    
}
