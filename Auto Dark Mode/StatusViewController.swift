//
//  StatusViewController.swift
//  Auto Dark Mode
//
//  Created by Nicolae Oprisan on 02/10/2018.
//  Copyright © 2018 OakGrove Software. All rights reserved.
//

import Cocoa

class StatusViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    static func freshController() -> StatusViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier()
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? StatusViewController else {
            fatalError("Why cant i find StatusViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
