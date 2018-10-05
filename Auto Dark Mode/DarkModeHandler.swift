//
//  DarkModeHandler
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 02/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import Solar
import CoreLocation

struct SolarRegistry {
    var today: Solar
    var tomorrow: Solar
}

struct DarkMode {
    private static let command = "tell application id \"com.apple.systemevents\" to tell appearance preferences to set dark mode to "
    
    static var isEnabled: Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
    
    static var isDisabled: Bool {
        return !isEnabled
    }
    
    static func enable() {
        if isEnabled {
            print("Dark mode already enabled")
            return
        }

        if DarkMode.toggle() {
            print("Enabled DarkMode")
        }
    }
    
    static func disable() {
        if isDisabled {
            print("Dark mode already disabled")
            return
        }

        if DarkMode.toggle() {
            print("Disabled Dark Mode")
        }
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

class DarkModeHandler: NSObject, CLLocationManagerDelegate, NSMenuDelegate {
    let initialDarkMode = DarkMode.isEnabled
    let locationManager = CLLocationManager()
    let notificationHandler = NotificationHandler()
    let dateHelper = DateHelper()
    var timerHandler = TimerHandler()
    var lastLocation: CLLocation?
    var solarHelper: SolarHelper?
    
    func initSolar() -> Bool {
        if let coordinate = lastLocation?.coordinate {
            let solarToday = Solar(for: dateHelper.now, coordinate: coordinate)
            let solarTommorow = Solar(for: dateHelper.tomorrow, coordinate: coordinate)
            let solarRegistry = SolarRegistry(today: solarToday!, tomorrow: solarTommorow!)
            solarHelper = SolarHelper(solarRegistry: solarRegistry, dateHelper: dateHelper)

            return true
        }
        
        return false
    }

    func initState() -> Bool {
        setDarkModeState(isDaytime: (solarHelper?.isDaytime)!)

        do {
            try timerHandler.initState(solar: solarHelper!)
            return true
        } catch let error as SolarError {
            print("Error: \(error.localizedDescription)")
        } catch let error as TimerError {
            print("Error: \(error.localizedDescription)")
        } catch {
            print("Generic internal error while trying to set timers")
        }

        return false
    }
    
    func setDarkModeState(isDaytime: Bool) {
        switch isDaytime {
        case true:
            DarkMode.disable()
        case false:
            DarkMode.enable()
        }
    }

    
    // LOCATION SPECIFIC METHODS
    func configLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 1000.0  // In meters.
        locationManager.delegate = self
    }

    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        handleLocationAuthorizationStatus(status: authorizationStatus)
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .authorizedAlways:
            configLocationManager()
            locationManager.startUpdatingLocation()
        case .restricted:
            notificationHandler.showAlert(
                title: "Access to Location Services is Restricted",
                message: "Parental Controls or a system administrator may be limiting your access to location services."
            )
        case .denied:
            print("I'm sorry - I can't show location. User has not authorized it")
            notificationHandler.showDeniedAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        guard initSolar() else { return }
        
        if initState() {
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        notificationHandler.showAlert(
            title: "Location Access Failure",
            message: "App could not access locations. Loation services may be unavailable or are turned off. Error code: \(error)"
        )
    }

    // INIT AND CLEANUP METHODS
    func restoreInitialMode() {
        guard DarkMode.isEnabled != initialDarkMode else { return }
        _ = DarkMode.toggle()
    }

    func onAppDidFinishLaunching() {
        startReceivingLocationChanges()
    }
    
    func onAppWillTerminate() {
        locationManager.stopUpdatingLocation()
        restoreInitialMode()
    }

    deinit {
        onAppWillTerminate()
    }
}
