//
//  Helpers.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import CoreLocation
import Solar


struct SolarRegistry {
    var today: Solar
    var tomorrow: Solar
}

struct DateHelper {
    var now: Date {
        return Date()
    }
    
    var tomorrow: Date {
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day); // +1 day
        
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: dateComponents, to: now)  // Add the DateComponents
        
        return tomorrow!
    }
    
    var startOfTomorrow: Date {
        return Calendar.current.startOfDay(for: tomorrow)
    }
}

class SolarHandler: AppManagedObject, AppManagerDelegate, AppLocationManagerDelegate, AppDelegateRegistrant {
    
    let dateHelper = DateHelper()
    var solarRegistry: SolarRegistry?
    var appLocationManager: AppLocationManager {
        get {
            return (manager.container?.AppLocationManager)!
        }
    }
    var delegates = [SolarHandlerDelegate]()

    func build(location: CLLocation) {
        let coordinate = location.coordinate
        
        let solarToday = Solar(for: dateHelper.now, coordinate: coordinate)
        let solarTommorow = Solar(for: dateHelper.tomorrow, coordinate: coordinate)
        
        solarRegistry = SolarRegistry(today: solarToday!, tomorrow: solarTommorow!)
        
        guard solarRegistry != nil else { return }
        didFinishLoading()
    }
    
    func addDelegate(newElement: SolarHandlerDelegate) {
        delegates.append(newElement)
    }
    
    var isDaytime: Bool {
        return solarRegistry!.today.isDaytime
    }

    var nextSunrise: Date {
        let result = dateHelper.now <= (solarRegistry!.today.sunrise)! ? solarRegistry!.today.sunrise! : solarRegistry!.tomorrow.sunrise!
        return result
    }
    
    var nextSunset: Date {
        let result = dateHelper.now <= (solarRegistry!.today.sunset)! ? solarRegistry!.today.sunset! : solarRegistry!.tomorrow.sunset!
        return result
    }
    
    var nextEvent: Date {
        let now = dateHelper.now
        
        switch true {
        case now <= solarRegistry!.today.sunrise!:
            return solarRegistry!.today.sunrise!
        case now <= solarRegistry!.today.sunset!:
            return solarRegistry!.today.sunset!
        case now <= solarRegistry!.tomorrow.sunrise!:
            return solarRegistry!.tomorrow.sunrise!
        case now <= solarRegistry!.tomorrow.sunset!:
            return solarRegistry!.tomorrow.sunset!
        default:
            return solarRegistry!.tomorrow.sunset!
        }
    }
    
    // Delegate calls
    // Own
    func didFinishLoading() {
        
        delegates.forEach({delegate in
            delegate.solarHandler(didFinishLoading: self)
        })
        
    }
    
    func registerToDelegateCallers() {
        // App Location Manager
        manager.container?.AppLocationManager.addDelegate(newDelegate: self)
    }

    // Called
    func appDidFinishLaunching(_ manager: AppManager) {
        
    }
    
    func appWillTerminate(_ manager: AppManager) {
        
    }
    
    func addManagerDelegate() {
        manager.addDelegate(newElement: self)
    }

    func appLocationManager(didUpdateLocation newLocation: CLLocation) {
        build(location: newLocation)
    }

}
