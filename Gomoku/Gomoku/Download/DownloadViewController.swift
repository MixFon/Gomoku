//
//  DownloadViewController.swift
//  Gomoku
//
//  Created by Михаил Фокин on 26.10.2021.
//

import Cocoa

class DownloadViewController: NSViewController {

	@IBOutlet weak var collectionView: NSCollectionView!
	
	var saves: [Save]?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		configureCollectionView()
		configure()
		self.saves = loadSaves()
		print("DownloadViewController")
    }
	
	@IBAction func pressClose(_ sender: NSButton) {
		let menuSB = NSStoryboard(name: "Main", bundle: nil)
		if let menuVC = menuSB.instantiateController(withIdentifier: "3DMenuID") as? StartViewController {
			self.view.window?.contentViewController = menuVC
		}
//		if let menuVC = self.storyboard?.instantiateController(withIdentifier: "3DMenuID") as? StartViewController{
//			//self.gomoku.ai?.task.interrupt()
//			self.view.window?.contentViewController = menuVC
//		}
	}
	
	/// Считываем массив сохнарений из файла и возвращает их
	private func loadSaves() -> [Save]? {
		let saveManager = SaveManager()
		return saveManager.getSaves()
	}
	
	private func configureCollectionView() {
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.isSelectable = true
		self.collectionView.allowsEmptySelection = true
		self.collectionView.allowsMultipleSelection = true
		self.collectionView.enclosingScrollView?.borderType = .noBorder
		self.collectionView.register(CollectionItem.self, forItemWithIdentifier: CollectionItem.itemIdentifier)
	}
	
	/// Метод необходим для настройки размещения ячеек
	private func configure() {
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.itemSize = NSSize(width: 225.0, height: 200.0)
		flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
		flowLayout.minimumInteritemSpacing = 20.0
		flowLayout.minimumLineSpacing = 20.0
		collectionView.collectionViewLayout = flowLayout
		view.wantsLayer = true
		collectionView.layer?.backgroundColor = NSColor.black.cgColor
	}

}

extension DownloadViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
	
	/// Определяет количество сектаров
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	/// Количество ячеек для каждой секции
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let saves = self.saves else { return 0 }
		return saves.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = self.collectionView.makeItem(withIdentifier: CollectionItem.itemIdentifier, for: indexPath)
		guard let saves = self.saves else { return item }
		guard let coolectionItem = item as? CollectionItem else { return item }
		guard let date = saves[indexPath.item].date else { return item }
		guard let pathImage = saves[indexPath.item].pathImage else { return item }
		guard let mode = saves[indexPath.item].mode else { return item }
		let url = URL(fileURLWithPath: pathImage)
		coolectionItem.imageV.image = NSImage(contentsOfFile: url.path)
		coolectionItem.lable.stringValue = "\(date) \(mode)"
		return coolectionItem
	}
	
	/// Вызывается при выборе сохранения
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		guard let saves = self.saves else { return }
		guard let indexPath = indexPaths.first else { return }
		let save = saves[indexPath.item]
		let menuSB = NSStoryboard(name: "Main", bundle: nil)
		if let gameVC = menuSB.instantiateController(withIdentifier: "GameVC") as? GameViewController {
			//gameVC.blackStonesOnBoard = save.blackPoints
			gameVC.whiteStartPointsOnBoard = save.whitePoints
			gameVC.blackStartPointsOnBoard = save.blackPoints
			if let mode = Gomoku.Mode(rawValue: save.mode ?? "") {
				gameVC.gomoku.setMode(mode: mode)
			}
			gameVC.gomoku.setCurrentStone(stone: save.stone ?? "")
			gameVC.gomoku.setCaptures(save.whiteCaptures ?? 0, save.blackCaptures ?? 0)
			gameVC.gomoku.setStartPointOnBouard(
				whitePoints: gameVC.whiteStartPointsOnBoard ?? [],
				blackPoints: gameVC.blackStartPointsOnBoard ?? []
			)
			self.view.window?.contentViewController = gameVC
		}
		print()
	}
	
}
