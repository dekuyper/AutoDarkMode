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

    static func toggle(_force: Bool? = nil) -> Bool {
 
        let flag = _force.map(String.init) ?? String(!isEnabled)
        let script = command + flag
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

    var delegate: DarkModeHandlerDelegate?

    func setDarkModeState(isDaytime: Bool) {
        switch isDaytime {
        case true:
            disableDarkMode()
        case false:
            enableDarkMode()
        }
    }

    func enableDarkMode() {
        if DarkMode.enable() {
            didToggle()
        }
    }

    func disableDarkMode() {
        if DarkMode.disable() {
            didToggle()
        }
    }

    // DELEGATE METHODS
    // OWN
    func didToggle() {
        
        delegate?.didToggleDarkMode(DarkMode.isEnabled)
        
    }
    
    // CALLED
    func addManagerDelegate() {
        manager.addDelegate(newElement: self)
    }
    
    func appDidFinishLaunching(_ manager: AppManager) {
        
    }
    
    func appWillTerminate(_ manager: AppManager) {
        
    }

    func setSolarHandlerDelegate() {
        
        solarHandler.delegate = self
        
    }

    func solarHandlerFinishedLoading(_ solarHandler: SolarHandler) {
        
        setDarkModeState(isDaytime: solarHandler.isDaytime)
        
    }
    
}

protocol DarkModeHandlerDelegate {
    
    func didToggleDarkMode(_ newValue: Bool)
    
}
