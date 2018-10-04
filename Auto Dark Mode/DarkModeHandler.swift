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
    var initStateIsSet = false
    var timersAreSet = false
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
        case .notDetermined:
            showAlert(
                title: "Access to Location Services is Not Determined",
                message: "Parental Controls or a system administrator may be limiting your access to location services. Ask them to."
            )
        case .restricted:
            showAlert(
                title: "Access to Location Services is Restricted",
                message: "Parental Controls or a system administrator may be limiting your access to location services. Ask them to."
            )
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
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
//        let alertController = UIAlertController(title: "Background Location Access Disabled", message: "In order to show the location weather forecast, please open this app's settings and set location access to 'While Using'.", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alertController.addAction(UIAlertAction(title: "Open Settings", style: .`default`, handler: { action in
//            if #available(iOS 10.0, *) {
//                let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
//                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
//            } else {
//                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
//                    UIApplication.shared.openURL(url as URL)
//                }
//            }
//        }))
//        self.present(alertController, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }

    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        // TODO: Filter coordinates that are from cache
        print(lastLocation.coordinate)
        solarLib = Solar(coordinate: lastLocation.coordinate)
        initState()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            print(error)
            // alert user he will need location approved for this to work
            return
        }
    }

    func initState() {
        if initStateIsSet {
            return
        }

        solarLib?.isDaytime != nil ? disableDarkMode() : enableDarkMode()

        do {
            try setTimers()
        } catch is SolarLibError {
            print("Internal error occured while trying to determine current position of the sun.")
        } catch {
            print("Generic internal error while trying to set timers")
        }

        initStateIsSet = true
    }

    func setTimers() throws {
        guard timersAreSet else {
            print()
            return
        }
        
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
