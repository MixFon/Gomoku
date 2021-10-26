//
//  DownloadViewController.swift
//  Gomoku
//
//  Created by Михаил Фокин on 26.10.2021.
//

import Cocoa

class DownloadViewController: NSViewController {

	@IBOutlet weak var collectionView: NSCollectionView!
	override func viewDidLoad() {
        super.viewDidLoad()
		configureCollectionView()
		configure()
		print("DownloadViewController")
    }

	func configureCollectionView() {
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.isSelectable = true
		self.collectionView.allowsEmptySelection = true
		self.collectionView.allowsMultipleSelection = true
		self.collectionView.enclosingScrollView?.borderType = .noBorder
		self.collectionView.register(CollectionItem.self, forItemWithIdentifier: CollectionItem.itemIdentifier)
	}
	
	private func configure() {
	  // 1
	  let flowLayout = NSCollectionViewFlowLayout()
	  flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
		flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
	  flowLayout.minimumInteritemSpacing = 20.0
	  flowLayout.minimumLineSpacing = 20.0
	  collectionView.collectionViewLayout = flowLayout
	  // 2
	  view.wantsLayer = true
	  // 3
	  collectionView.layer?.backgroundColor = NSColor.black.cgColor
	}

}

extension DownloadViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
	
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 4
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return 4
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = self.collectionView.makeItem(withIdentifier: CollectionItem.itemIdentifier, for: indexPath)
		guard let coolectionItem = item as? CollectionItem else { return item }
		coolectionItem.lable.stringValue = "Hello"
		return coolectionItem
	}
	
}
