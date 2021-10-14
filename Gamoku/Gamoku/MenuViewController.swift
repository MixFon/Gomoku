//
//  MenuViewController.swift
//  Gamoku
//
//  Created by Михаил Фокин on 12.10.2021.
//

import Cocoa

class MenuViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
	@IBAction func pressStart(_ sender: NSButton) {
		if let gameVC = self.storyboard?.instantiateController(withIdentifier: "GameVC") as? GameViewController {
			self.view.window?.contentViewController = gameVC
		}
	}
}
