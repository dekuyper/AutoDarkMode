//
//  AppManager.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation
import CoreLocation

protocol ManagedObject {
    
    var manager: AppManager { get }
    
    init(appManager: AppManager)

}

class AppManagedObject: NSObject, ManagedObject {
    
    let manager: AppManager
    
    required init(appManager: AppManager) {
        manager = appManager
        super.init()
    }
    
}

struct AppContainer {
    let AppLocationManager: AppLocationManager
    let DarkModeHandler: DarkModeHandler
    let MenuHandler: MenuHandler
    let NotificationHandler: NotificationHandler
    let SolarHandler: SolarHandler
    let TimerHandler: TimerHandler
}

class AppManager: NSObject {
    private var delegates: [AppManagerDelegate] = [AppManagerDelegate]()
    var container: AppContainer?

    func addDelegate(newElement: AppManagerDelegate) {
        delegates.append(newElement)
    }
    
    func appDidFinishLaunching() {
        if !SystemEvents.isActive {
            print("TODO: Activate system events app")
            return
        }
        
        container = AppContainer(
            AppLocationManager: AppLocationManager(appManager: self),
            DarkModeHandler: DarkModeHandler(appManager: self),
            MenuHandler: MenuHandler(appManager: self),
            NotificationHandler: NotificationHandler(appManager: self),
            SolarHandler: SolarHandler(appManager: self),
            TimerHandler: TimerHandler(appManager: self)
        )
        
        container?.AppLocationManager.registerToDelegateCallers()
        container?.SolarHandler.registerToDelegateCallers()
        container?.MenuHandler.registerToDelegateCallers()
        container?.TimerHandler.registerToDelegateCallers()
        container?.DarkModeHandler.registerToDelegateCallers()
        container?.NotificationHandler.registerToDelegateCallers()
        
        delegateAppDidFinishLaunching()
    }
    
    func appWillTerminate() {
        
        delegateAppWillTerminate()
        
    }

    private func delegateAppDidFinishLaunching() {
        
        delegates.forEach({delegate in
            delegate.appDidFinishLaunching(self)
        })
        
    }

    private func delegateAppWillTerminate() {
        
        delegates.forEach({delegate in
            delegate.appWillTerminate(self)
        })
        
    }

}


// Delegate Protocols

protocol AppDelegateRegistrant {
    
    func registerToDelegateCallers()

}

protocol AppManagerDelegate: AppDelegateRegistrant {
    
    func appDidFinishLaunching(_ manager: AppManager)
    
    func appWillTerminate(_ manager: AppManager)
    
}

protocol AppLocationManagerDelegate: AppDelegateRegistrant {
    
    func appLocationManager(didUpdateLocation newLocation: CLLocation)
    
}

protocol DarkModeHandlerDelegate: AppDelegateRegistrant {
    
    func darkModeHandler(didToggleDarkMode newValue: Bool)
    
}

protocol SolarHandlerDelegate: AppDelegateRegistrant {
    
    func solarHandler(didFinishLoading solarHandler: SolarHandler)
    
}

protocol TimerHandlerDelegate: AppDelegateRegistrant {
    
    func timerHandler(didFinishLoading timerHandler: TimerHandler)
    
}
