//
//  MenuViewController.swift
//  Gamoku
//
//  Created by Михаил Фокин on 12.10.2021.
//

import Cocoa


// MARK: УБРАТЬ!!!!
class MenuViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
	@IBAction func pressStart(_ sender: NSButton) {
		if let gameVC = self.storyboard?.instantiateController(withIdentifier: "GameVC") as? GameViewController {
			if sender.identifier?.rawValue == "pvc" {
				gameVC.gomoku.setMode(mode: .pvc)
			} else {
				gameVC.gomoku.setMode(mode: .pvp)
			}
			self.view.window?.contentViewController = gameVC
		}
	}
	
	@IBAction func pressDownload(_ sender: NSButton) {
		let downloadSB = NSStoryboard(name: "DounloadSourybouard", bundle: nil)
		if let download = downloadSB.instantiateController(withIdentifier: "Download") as? DownloadViewController {
			self.view.window?.contentViewController = download
		}
	}
	
	@IBAction func pressExit(_ sender: Any) {
		NSApplication.shared.terminate(self)
	}
	
}
