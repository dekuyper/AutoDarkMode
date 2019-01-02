//
//  SystemCheck.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 09/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Foundation

struct SystemEvents {
    static var isActive: Bool {
        get {
            let testScript = """
                            tell app "System Events" to count processes whose name is "System Events"
                            """

            do {
                let result = try AppleScript.run(myAppleScript: testScript)
                return result == "1"
            } catch {
                return false
            }

        }
    }
}
