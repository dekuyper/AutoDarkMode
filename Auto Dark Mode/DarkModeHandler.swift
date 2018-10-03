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

enum SolarLibError: Error {
    case getCivilSunrise
    case getCivilSunset
}

class DarkModeHandler: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var solarLib: Solar?
    var initStateIsSet = false
    var timersAreSet = false
    var timers: [Timer]?
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 1000.0  // In meters.
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        // TODO: Filter coordinates that are from cache
        solarLib = Solar(coordinate: lastLocation.coordinate)
        initDarkModeState()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            // alert user he will need location approved for this to work
            return
        }
    }

    func initDarkModeState() {
        if initStateIsSet {
            return
        }

        if solarLib?.isDaytime ?? true {
            disableDarkMode()
        } else {
            enableDarkMode()
        }

        do {
            try setTimers()
        } catch is SolarLibError {
            // Alert notification handler
        } catch {
            // Alert notification handler
        }

        initStateIsSet = true
    }
    
    func setTimers() throws {
        guard timersAreSet else {return}
        
        let now = Date()
        let sunriseDate = try getSunriseDate()
        let sunsetDate = try getSunsetDate()

        if now < sunriseDate {
            addSunriseTimer(sunriseDate: sunriseDate)
        }
        
        if now < sunsetDate {
            addSunsetTimer(sunsetDate: sunsetDate)
        }

        timersAreSet = true
        locationManager.stopUpdatingLocation()
    }
    
    func invalidateTimers() {
        timers?.forEach({timer in timer.invalidate()})
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

    func addSunriseTimer(sunriseDate: Date) {
        addTimer(date: sunriseDate, flag: false)
    }

    func addSunsetTimer(sunsetDate: Date) {
        addTimer(date: sunsetDate, flag: true)
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
