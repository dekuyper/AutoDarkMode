//
//  AppManager.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 05/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation

class AppManager: NSObject {
    var delegate: AppManagerDelegate?
    
    func appDidFinishLaunching() {
        
        delegate?.appDidFinishLaunching()
        
    }
}

protocol AppManagerDelegate {
    
    func appDidFinishLaunching()
    
}
