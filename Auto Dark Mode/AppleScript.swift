//
//  AppleScript.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 02/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation

struct AppleScript {
    static func run(myAppleScript: String) ->Bool {
        var error: NSDictionary?
        let result = NSAppleScript(source: myAppleScript)?.executeAndReturnError(&error).stringValue
        
        if result == nil {
            print(error)
            return false
        }
        
        print(result)
        return true
    }
}
