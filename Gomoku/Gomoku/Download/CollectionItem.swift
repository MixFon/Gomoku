//
//  CollectionItem.swift
//  Gomoku
//
//  Created by Михаил Фокин on 26.10.2021.
//

import Cocoa

class CollectionItem: NSCollectionViewItem {

	@IBOutlet weak var lable: NSTextField!
	@IBOutlet weak var imageV: NSImageView!
	
	static let itemIdentifier = NSUserInterfaceItemIdentifier("itemIdentifier")

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imageV.wantsLayer = true
		self.imageV.layer?.borderWidth = 1.0
		//self.imageV.layer?.borderColor = NSColor.red.cgColor
		self.imageV.layer?.cornerRadius = 10.0
		self.imageV.layer?.masksToBounds = true
	}
}
