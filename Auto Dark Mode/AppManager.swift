//
//  AppManager.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation


protocol AppManagerDelegate {
    
    func appDidFinishLaunching(_ manager: AppManager)
    
    func appWillTerminate(_ manager: AppManager)
    
    func addManagerDelegate()

}

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
    private var delegates: [AppManagerDelegate]
    var container: AppContainer?
    
    override init() {
        delegates = [AppManagerDelegate]()
    }
    
    func addDelegate(newElement: AppManagerDelegate) {
        delegates.append(newElement)
    }
    
    func appDidFinishLaunching() {
        
        container = AppContainer(
            AppLocationManager: AppLocationManager(appManager: self),
            DarkModeHandler: DarkModeHandler(appManager: self),
            MenuHandler: MenuHandler(appManager: self),
            NotificationHandler: NotificationHandler(appManager: self),
            SolarHandler: SolarHandler(appManager: self),
            TimerHandler: TimerHandler(appManager: self)
        )
        
        container?.AppLocationManager.addManagerDelegate()
        container?.SolarHandler.addManagerDelegate()
        container?.MenuHandler.addManagerDelegate()
        container?.TimerHandler.addManagerDelegate()
        container?.DarkModeHandler.addManagerDelegate()
        container?.NotificationHandler.addManagerDelegate()
        
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
