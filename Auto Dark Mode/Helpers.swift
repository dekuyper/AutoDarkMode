//
//  Helpers.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation


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

struct SolarHelper {
    var solarRegistry: SolarRegistry
    var dateHelper: DateHelper

    var isDaytime: Bool {
        return solarRegistry.today.isDaytime
    }

    var nextSunrise: Date {
        let result = dateHelper.now <= (solarRegistry.today.sunrise)! ? solarRegistry.today.sunrise! : solarRegistry.tomorrow.sunrise!
        return result
    }
    
    var nextSunset: Date {
        let result = dateHelper.now <= (solarRegistry.today.sunset)! ? solarRegistry.today.sunset! : solarRegistry.tomorrow.sunset!
        return result
    }
    
    var nextEvent: Date {
        let now = dateHelper.now
        
        switch true {
        case now <= solarRegistry.today.sunrise!:
            return solarRegistry.today.sunrise!
        case now <= solarRegistry.today.sunset!:
            return solarRegistry.today.sunset!
        case now <= solarRegistry.tomorrow.sunrise!:
            return solarRegistry.tomorrow.sunrise!
        case now <= solarRegistry.tomorrow.sunset!:
            return solarRegistry.tomorrow.sunset!
        default:
            return solarRegistry.tomorrow.sunset!
        }
    }
    
}
