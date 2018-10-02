//
//  LocationSuntime.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 02/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import Solar
import CoreLocation

class LocationSuntime: NSObject {
    let solar: Solar
    let public static coordinate: CLLocation
    
    init() {
        solar = Solar(coordinate: <#T##CLLocationCoordinate2D#>)
    }
}
