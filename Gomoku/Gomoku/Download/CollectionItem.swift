//
//  CollectionItem.swift
//  Gomoku
//
//  Created by Михаил Фокин on 26.10.2021.
//

import Cocoa

class CollectionItem: NSCollectionViewItem {

	@IBOutlet weak var lable: NSTextField!
	
	static var itemIdentifier = NSUserInterfaceItemIdentifier("itemIdentifier")

	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.wantsLayer = true
		view.layer?.cornerRadius = 8.0
		print("collectionItem")
	}
}
