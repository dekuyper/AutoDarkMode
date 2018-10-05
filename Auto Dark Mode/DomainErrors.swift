//
//  DomainErrors.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

enum LocationManagerError: Error {
    case noLocationProvided(message: String)
}

enum SolarError: Error {
    case getCivilSunrise
    case getCivilSunset
    case nextEvent
}

enum TimerError: Error {
    case onSet(message: String)
}
