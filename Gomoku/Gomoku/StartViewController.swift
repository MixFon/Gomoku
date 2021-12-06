//
//  StartViewController.swift
//  Gomoku
//
//  Created by Михаил Фокин on 06.12.2021.
//

import Cocoa
import SceneKit
import QuartzCore

class StartViewController: NSViewController {
	
	let scene = SCNScene(named: "art.scnassets/start_menu.scn")!
	
	var menuItem = MenuItem(rawValue: 0)
	
	enum MenuItem: UInt8 {
		case zero = 0
		case one = 1
		case two = 2
		case three = 3
		case four = 4
	}
	
	enum Menu: String {
		case startPvC = "Start PvC"
		case startPvP = "Start PvP"
		case loading = "Loading"
		case exit = "Exit"
	}

    override func viewDidLoad() {
		super.viewDidLoad()
		
		//setLight()
		setStones()
		//movingCircle()
		
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		//scnView.snapshot()
		// set the scene to the view
		scnView.scene = self.scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// configure the view
		scnView.backgroundColor = NSColor.black
		
		// Add a click gesture recognizer
		let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
		var gestureRecognizers = scnView.gestureRecognizers
		gestureRecognizers.insert(clickGesture, at: 0)
		scnView.gestureRecognizers = gestureRecognizers
    }
    
	@objc
	func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// check what nodes are clicked
		let p = gestureRecognizer.location(in: scnView)
		let hitResults = scnView.hitTest(p, options: [:])
		// check that we clicked on at least one object
		if hitResults.count > 0 {
			// retrieved the first clicked object
			let node = hitResults[0].node
			if node.name == "floor" { return }
			guard let name = node.name else { return }
			let caseMenu = Menu(rawValue: name)
			//guard let name = NamesNode(rawValue: node.name ?? "") else { return }
			nodeShine(node: node, color: .blue)
			moveFieldsTo(position: node.position)
			switch caseMenu {
			case .startPvC:
				if self.menuItem == .one {
					startGameVC(mode: .pvc)
				} else {
					self.menuItem = .one
				}
			case .startPvP:
				if self.menuItem == .two {
					startGameVC(mode: .pvp)
				} else {
					self.menuItem = .two
				}
			case .loading:
				if self.menuItem == .three {
					startLoading()
				} else {
					self.menuItem = .three
				}
			case .exit:
				if self.menuItem == .four {
					NSApplication.shared.terminate(self)
				} else {
					self.menuItem = .four
				}
			default:
				break
			}
		}
	}
	
	/// Запуск Gomoku с установленным модом.
	private func startGameVC(mode: Gomoku.Mode) {
		if let gameVC = self.storyboard?.instantiateController(withIdentifier: "GameVC") as? GameViewController {
			gameVC.gomoku.setMode(mode: mode)
			self.view.window?.contentViewController = gameVC
		}
	}
	
	/// Запуск экрана с загрузкой игр
	private func startLoading() {
		let loadingSB = NSStoryboard(name: "DounloadSourybouard", bundle: nil)
		if let loading = loadingSB.instantiateController(withIdentifier: "Download") as? DownloadViewController {
			self.view.window?.contentViewController = loading
		}
	}
	
	private func moveFieldsTo(position: SCNVector3) {
		let positionWhite = SCNVector3(10, 0, position.z - 3)
		let positionBlack = SCNVector3(-10, 0, position.z - 3)
		if let fieldWhite = self.scene.rootNode.childNodes.first(where: {$0.name == "field_white"} ) {
			fieldWhite.runAction(SCNAction.move(to: positionBlack, duration: 1))
		}
		if let fieldBlack = self.scene.rootNode.childNodes.first(where: {$0.name == "field_black"} ) {
			fieldBlack.runAction(SCNAction.move(to: positionWhite, duration: 1))
		}
		if let area = self.scene.rootNode.childNodes.first(where: {$0.name == "area"} ) {
			let positionAria = SCNVector3(area.position.x, area.position.y, position.z - 3)
			area.runAction(SCNAction.move(to: positionAria, duration: 1))
		}
	}
	
	/// Установка источника света
	private func setLight() {
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = .omni
		lightNode.position = SCNVector3(x: 0, y: 20, z: 0)
		self.scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = .ambient
		ambientLightNode.light!.color = NSColor.darkGray
		scene.rootNode.addChildNode(ambientLightNode)
	}
	
	/// Установка игральных камней по разные стороны играков
	private func setStones() {
		guard let imageWhite = NSImage(named: "white_stone") else { return }
		guard let imageBlack = NSImage(named: "black_stone") else { return }
		for _ in 0...180 {
			var ramdomX = Double.random(in: 10...20)
			var randomY = Double.random(in: 4...8)
			var ramdomZ = Double.random(in: -10...15)
			let whiteNode = setOneNode(position: SCNVector3(ramdomX, randomY, ramdomZ))
			whiteNode.geometry?.firstMaterial?.diffuse.contents = imageWhite
			
			ramdomX = Double.random(in: -20...(-10))
			randomY = Double.random(in: 4...8)
			ramdomZ = Double.random(in: -10...15)
			let blackNode = setOneNode(position: SCNVector3(ramdomX, randomY, ramdomZ))
			blackNode.geometry?.firstMaterial?.diffuse.contents = imageBlack
		}
	}
	
	/// Устанавливает один шар в указанную точку.
	private func setOneNode(position: SCNVector3) -> SCNNode {
		let node = SCNNode()
		//node.name = NamesNode.nameStone.rawValue
		node.geometry = SCNSphere(radius: 0.3)
		node.position = position
		node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		self.scene.rootNode.addChildNode(node)
		return node
	}
	
	/// Подсвечивание node указанного цвета
	private func nodeShine(node: SCNNode, color: NSColor) {
		// get its material
		let material = node.geometry!.firstMaterial!
		
		// highlight it
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 0.5
		
		// on completion - unhighlight
		SCNTransaction.completionBlock = {
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.5
			
			material.emission.contents = NSColor.black
			
			SCNTransaction.commit()
		}
		
		material.emission.contents = color
		
		SCNTransaction.commit()
	}
	
	
}
