import Foundation
import Solar
import CoreLocation

class LocationSunTime: NSObject {
    let solar: Solar
    let location = LocationManagerDelegate()

    override init() {
        let coordinate = CLLocationCoordinate2D(latitude: 44.42, longitude: 26.10)
        solar = Solar(coordinate: coordinate)!
    }
    
    func sunrise() -> Date? {
        return solar.civilSunrise
    }
    
    func sunset() -> Date? {
        return solar.civilSunset
    }
    
    func isDaytime() -> Bool {
        return solar.isDaytime
    }
    
    func isNightTime() -> Bool {
        return solar.isNighttime
    }
}
