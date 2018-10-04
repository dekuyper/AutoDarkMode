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

class DarkModeHandler: NSObject, CLLocationManagerDelegate, NSMenuDelegate {
    let initialDarkMode = DarkMode.isEnabled
    let locationManager = CLLocationManager()
    let notificationHelper = NotificationHelper()
    var solarLib: Solar?
    var switchModeTimers = [Timer]()
    var alertTimers = [Timer]()
    var nextRunningTimer: Timer?

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
            notificationHelper.showAlert(
                title: "Access to Location Services is Restricted",
                message: "Parental Controls or a system administrator may be limiting your access to location services."
            )
        case .denied:
            print("I'm sorry - I can't show location. User has not authorized it")
            notificationHelper.showDeniedAlert()
        }
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
            print("Rebuilding the menu")
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        notificationHelper.showAlert(
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
        invalidateTimers()

        let sunriseDate = try getSunriseDate()
        let sunsetDate = try getSunsetDate()
        let now = Date()

        if now < sunriseDate {
            addSunriseTimer(sunriseDate: sunriseDate)
        }
        
        if now < sunsetDate {
            addSunsetTimer(sunsetDate: sunsetDate)
        }

        setNextRunningTimer(now: now)
    }

    func getNextRunningTimer() -> Timer? {
        return nextRunningTimer
    }

    func setNextRunningTimer(now: Date) {
        let filteredTimers = switchModeTimers.sorted(by: {$0.fireDate < $1.fireDate})
            .filter({ $0.fireDate > now })

        nextRunningTimer = filteredTimers.first!
    }

    func addSunriseTimer(sunriseDate: Date) {
        let timer = Timer(fireAt: sunriseDate, interval: 0, target: self, selector: #selector(disableDarkMode), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        switchModeTimers.append(timer)
    }

    func addSunsetTimer(sunsetDate: Date) {
        let timer = Timer(fireAt: sunsetDate, interval: 0, target: self, selector: #selector(enableDarkMode), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        switchModeTimers.append(timer)
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

    func onAppFinishedLaunching() {
        startReceivingLocationChanges()
    }
    
    func onAppWillTerminate() {
        locationManager.stopUpdatingLocation()
        invalidateTimers()
        DarkMode.toggle(_force: initialDarkMode)
    }
    
    func invalidateTimers() {
        switchModeTimers.forEach({timer in
            timer.invalidate()
        })
        switchModeTimers.removeAll()

        alertTimers.forEach({timer in
            timer.invalidate()
        })
        alertTimers.removeAll()
    }

    deinit {
        onAppWillTerminate()
    }
}
