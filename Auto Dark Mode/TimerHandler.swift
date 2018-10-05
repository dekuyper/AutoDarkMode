//
//  TimerHandler.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation

class TimerHandler: NSObject {
    var switchModeTimers = [Timer]()
    var alertTimers = [Timer]()
    var nextRunningTimer: Timer?
    var solarHelper: SolarHandler?
    let dateHelper = DateHelper()

    func initState(solar: SolarHandler) throws {
        solarHelper = solar

        scheduleSunriseTimer(sunriseDate: (solarHelper!.nextSunrise))
        scheduleSunsetTimer(sunsetDate: (solarHelper!.nextSunset))
        
        try updateNextRunningTimer()
    }
    
    func updateTimers() {
        
    }
    
    func getNextRunningTimer() -> Timer? {
        return nextRunningTimer
    }
    
    func updateNextRunningTimer() throws {
        let now = dateHelper.now
        guard switchModeTimers.count > 0 else { throw TimerError.onSet(message: "switchModeTimers count is 0") }
        
        let filteredTimers = switchModeTimers.sorted(by: {$0.fireDate < $1.fireDate})
            .filter({ $0.fireDate > now })
        
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
        DarkMode.enable()
    }
    
    @objc func disableDarkMode() {
        DarkMode.disable()
    }

    func onAppDidFinishLaunching() {
        
    }
    
    func onAppWillTerminate() {
        invalidateTimers()
    }
    
    deinit {
        onAppWillTerminate()
    }

}
