//
//  AppLocationManagerDelegate.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import CoreLocation

class AppLocationManager: AppManagedObject, AppManagerDelegate, CLLocationManagerDelegate {
    
    private var delegates = [AppLocationManagerDelegate]()

    let locationManager = CLLocationManager()
    var notificationHandler: NotificationHandler {
        get {
            return (manager.container?.NotificationHandler)!
        }
    }

    func addDelegate(newDelegate: AppLocationManagerDelegate) {
        delegates.append(newDelegate)
    }

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
            print("Location authorization status: Not Determined")
            configLocationManager()
            locationManager.startUpdatingLocation()
            
        case .authorizedAlways:
            print("Location authorization status: Authorized Always")
            locationManager.startUpdatingLocation()
            
        case .restricted:
            notificationHandler.locationPermissions(restricted: "")
        
        case .denied:
            print("I'm sorry - I can't show location. User has not authorized it")
            notificationHandler.locationPermissions(denied: "")
        }
    }
    
    // Location Manager Events
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last!
        
        didUpdateLocation(newLocation: lastLocation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        notificationHandler.locationPermissions(failed: "\(error)")
    }

    // App delegate calls
    func registerToDelegateCallers() {
        manager.addDelegate(newElement: self)
    }
    
    func appDidFinishLaunching(_ manager: AppManager) {
        startReceivingLocationChanges()
    }
    
    func appWillTerminate(_ manager: AppManager) {
        locationManager.startUpdatingLocation()
    }
    
    func didUpdateLocation(newLocation: CLLocation) {
        delegates.forEach({delegate in
            delegate.appLocationManager(didUpdateLocation: newLocation)
        })
    }
    
}
