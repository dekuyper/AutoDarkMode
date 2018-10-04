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
import UserNotifications

enum SolarLibError: Error {
    case getCivilSunrise
    case getCivilSunset
}

class DarkModeHandler: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var solarLib: Solar?
    var timers: [Timer]?

    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        handleLocationAuthorizationStatus(status: authorizationStatus)
    }

    func configLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 1000.0  // In meters.
        locationManager.delegate = self
    }

    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .authorizedAlways:
            configLocationManager()
            locationManager.startUpdatingLocation()
        case .restricted:
            showAlert(
                title: "Access to Location Services is Restricted",
                message: "Parental Controls or a system administrator may be limiting your access to location services."
            )
        case .denied:
            print("I'm sorry - I can't show location. User has not authorized it")
            statusDeniedAlert()
        }
    }

    func showAlert(title: String, message: String) {
        print(
            "Title: \(title)",
            "Message: \(message)"
        )
    }

    func statusDeniedAlert() {
        print("Location access denied")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }

    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        solarLib = Solar(coordinate: lastLocation.coordinate)
        if initState() {
            print("Stopping location gathering")
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(
            title: "Location Access Failure",
            message: "App could not access locations. Loation services may be unavailable or are turned off. Error code: \(error)"
        )
    }

    func initState() -> Bool {
        let isDaytime = (solarLib?.isDaytime)!
        setDarkModeState(isDaytime: isDaytime)

        do {
            try setTimers()
        } catch is SolarLibError {
            print("Internal error occured while trying to determine current position of the sun.")
            return false
        } catch {
            print("Generic internal error while trying to set timers")
            return false
        }
        
        return true
    }
    
    func setDarkModeState(isDaytime: Bool) {
        switch isDaytime {
        case true:
            disableDarkMode()
        case false:
            enableDarkMode()
        }
    }

    func setTimers() throws {
        let now = Date()
        let sunriseDate = try getSunriseDate()
        let sunsetDate = try getSunsetDate()

        if now < sunriseDate {
            addSunriseTimer(sunriseDate: sunriseDate)
        }
        
        if now < sunsetDate {
            addSunsetTimer(sunsetDate: sunsetDate)
        }
    }
    
    func invalidateTimers() {
        timers?.forEach({timer in timer.invalidate()})
        timers?.removeAll()
    }

    func addSunriseTimer(sunriseDate: Date) {
        addTimer(date: sunriseDate, flag: false)
    }
    
    func addSunsetTimer(sunsetDate: Date) {
        addTimer(date: sunsetDate, flag: true)
    }

    func addTimer(date: Date, flag: Bool) {
        let timer: Timer
        
        if flag {
            timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(enableDarkMode), userInfo: nil, repeats: false)
        } else {
            timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(disableDarkMode), userInfo: nil, repeats: false)
        }
        
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        timers?.append(timer)
    }

    func getSunriseDate() throws  -> Date {
        guard let sunriseDate = solarLib?.civilSunrise else { throw SolarLibError.getCivilSunrise }
        return sunriseDate
    }
    
    func getSunsetDate() throws -> Date {
        guard let sunsetDate = solarLib?.civilSunset else { throw SolarLibError.getCivilSunset }
        return sunsetDate
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
