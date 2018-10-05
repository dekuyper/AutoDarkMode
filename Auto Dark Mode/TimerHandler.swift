//
//  TimerHandler.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation

class TimerHandler: AppManagedObject, AppManagerDelegate, SolarHandlerDelegate {
    
    var delegates: [TimerHandlerDelegate] = [TimerHandlerDelegate]()
    var switchModeTimers = [Timer]()
    var alertTimers = [Timer]()
    var nextRunningTimer: Timer?
    var solarHandler: SolarHandler {
        get {
            return (manager.container?.SolarHandler)!
        }
    }
    var darkModeHandler: DarkModeHandler {
        get {
            return (manager.container?.DarkModeHandler)!
        }
    }
    
    let dateHelper = DateHelper()

    func initState() {
        scheduleSunriseTimer(sunriseDate: (solarHandler.nextSunrise))
        scheduleSunsetTimer(sunsetDate: (solarHandler.nextSunset))
        
        updateNextRunningTimer()
        
        //=================//
        didFinishLoading()
    }
    
    func updateTimers() {
        
    }
    
    func updateNextRunningTimer() {
        guard switchModeTimers.count > 0 else { return }

        let filteredTimers = switchModeTimers.sorted(by: {$0.fireDate < $1.fireDate})
            .filter({ $0.fireDate > dateHelper.now })
        
        nextRunningTimer = filteredTimers.first!
    }
    
    func scheduleSunriseTimer(sunriseDate: Date) {
        let timer = Timer(fireAt: sunriseDate, interval: 0, target: self, selector: #selector(disableDarkMode), userInfo: nil, repeats: false)
        timer.tolerance = 30
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        switchModeTimers.append(timer)
    }
    
    func scheduleSunsetTimer(sunsetDate: Date) {
        let timer = Timer(fireAt: sunsetDate, interval: 0, target: self, selector: #selector(enableDarkMode), userInfo: nil, repeats: false)
        timer.tolerance = 30
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        switchModeTimers.append(timer)
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
    
    @objc func enableDarkMode() {
        darkModeHandler.enable()
    }
    
    @objc func disableDarkMode() {
        darkModeHandler.disable()
    }

    // DELEGATE CALLS
    func didFinishLoading() {
        
        delegates.forEach({delegate in
            delegate.timerHandler(didFinishLoading: self)
        })

    }
    
    func addDelegate(newElement: TimerHandlerDelegate) {
        delegates.append(newElement)
    }

    func solarHandler(didFinishLoading solarHandler: SolarHandler) {
        initState()
        
    }

    func appDidFinishLaunching(_ manager: AppManager) {
        
    }
    
    func appWillTerminate(_ manager: AppManager) {
        invalidateTimers()
    }
    
    func registerToDelegateCallers() {
        manager.addDelegate(newElement: self)
        solarHandler.addDelegate(newElement: self)
    }

}
