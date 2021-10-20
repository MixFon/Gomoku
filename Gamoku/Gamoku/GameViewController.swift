//
//  GameViewController.swift
//  Gamoku
//
//  Created by Михаил Фокин on 12.10.2021.
//

import AppKit
import SceneKit
import QuartzCore

class GameViewController: NSViewController {
	
	let scene = SCNScene(named: "art.scnassets/gomoku.scn")!
	
	let gomoku = Gomoku()
	
	/// Высона на которую устанавливаются pins
	let y = 0.5
	
	var whiteStonesOnBoard = [(SCNNode, Point?)]()
	var whiteStonesOnFloor = [(SCNNode, Point?)]()
	var blackStonesOnBoard = [(SCNNode, Point?)]()
	var blackStonesOnFloor = [(SCNNode, Point?)]()
	
	var sequsens = SCNAction()
	
	let radiusPin: CGFloat = 0.15
	let namePin = "pin"
	let radiusStone: CGFloat = 0.3
	let nameStone = "stone"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		self.gomoku.delegate = self
		setLight()
		setEmptyNodes()
		setStones()
		//movingCircle()
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
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
	
	/// Установка пустых сферических нод
	private func setEmptyNodes() {
		for i in -9...9 {
			for j in -9...9 {
				let position = SCNVector3(Double(i), self.y, Double(j))
				let node = SCNNode()
				node.geometry = SCNSphere(radius: self.radiusPin)
				//node.geometry?.firstMaterial?.normal.contents = NSColor.black
				node.position = position
				node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
				node.name = self.namePin
				self.scene.rootNode.addChildNode(node)
			}
		}
	}
	
	/// Установка игральных камней по разные стороны играков
	private func setStones() {
		guard let imageWhite = NSImage(named: "white_stone") else { return }
		guard let imageBlack = NSImage(named: "black_stone") else { return }
		for _ in 0...180 {
			var ramdomX = Double.random(in: -10...10)
			var randomY = Double.random(in: 2...4)
			var ramdomZ = Double.random(in: 11...15)
			let whiteNode = setOneNode(position: SCNVector3(ramdomX, randomY, ramdomZ))
			whiteNode.geometry?.firstMaterial?.diffuse.contents = imageWhite
			self.whiteStonesOnFloor.append((whiteNode, nil))
			
			ramdomX = Double.random(in: -10...10)
			randomY = Double.random(in: 2...4)
			ramdomZ = Double.random(in: -15...(-11))
			let blackNode = setOneNode(position: SCNVector3(ramdomX, randomY, ramdomZ))
			blackNode.geometry?.firstMaterial?.diffuse.contents = imageBlack
			self.blackStonesOnFloor.append((blackNode, nil))
		}
	}
	
	/// Устанавливает один шар в указанную точку.
	private func setOneNode(position: SCNVector3) -> SCNNode {
		let node = SCNNode()
		node.name = self.nameStone
		node.geometry = SCNSphere(radius: self.radiusStone)
		node.position = position
		node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		self.scene.rootNode.addChildNode(node)
		return node
	}
	
	/// Установка источника света
	private func setLight() {
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = .omni
		lightNode.position = SCNVector3(x: 0, y: 6, z: 0)
		self.scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = .ambient
		ambientLightNode.light!.color = NSColor.darkGray
		scene.rootNode.addChildNode(ambientLightNode)
	}
	
	/// Передвижение камня в указанную координату. Содержит два движения вверх и вниз
	private func moveStone(point: Point, stone: SCNNode) {
		//let stone = self.stones.randomElement()
		let position = SCNVector3(Double(point.x), self.y , Double(point.y))
		let positionUp = SCNVector3(position.x, position.y + 3, position.z)
		stone.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
		let moveUp = SCNAction.move(to: positionUp, duration: 0.7)
		let moveDown = SCNAction.move(to: position, duration: 0.2)
		let sequsens = SCNAction.sequence([moveUp, moveDown])
		//stone.animation
		stone.runAction(sequsens)
		//randomElem?.runAction(SCNAction.move(to: position, duration: 1))
		//randomElem
		//randomElem?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		//randomElem?.position = position
		//result.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
	}
	
	/// Движение по окружности
	private func movingCircle() {
		let h = 0
		let l = 15
		let duration: TimeInterval = 4
		let moveOne = SCNAction.move(to: SCNVector3(l, h, l), duration: duration)
		let moveTwo = SCNAction.move(to: SCNVector3(l, h, -l), duration: duration)
		let moveThree = SCNAction.move(to: SCNVector3(-l, h, -l), duration: duration)
		let moveFour = SCNAction.move(to: SCNVector3(-l, h, l), duration: duration)
		let sequsens = SCNAction.sequence([moveOne, moveTwo, moveThree, moveFour])
		let field = self.scene.rootNode.childNode(withName: "field", recursively: false)
		field?.runAction(SCNAction.repeatForever(sequsens))
	}
	
	/// Закрывает сцену и преходит к предыдущему окну.
	private func exitScene() {
		if let menuVC = self.storyboard?.instantiateController(withIdentifier: "MenuVC") as? MenuViewController {
			self.view.window?.contentViewController = menuVC
		}
	}
	
	/// Удаление камней с доски анимационно
	private func deleteStones(stones: [SCNNode]) {
//		let stones = self.scene.rootNode.childNodes.filter( {
//			($0.position.x == CGFloat(points.0.x) &&
//			$0.position.z == CGFloat(points.0.y) ||
//			$0.position.x == CGFloat(points.1.x) &&
//			$0.position.z == CGFloat(points.1.y)) &&
//			$0.name == self.nameStone
//		} )
		print(stones)
		for stone in stones {
			let randX = Double.random(in: 10...15)
			let randY = Double.random(in: 3...8)
			let randZ = Double.random(in: -7...7)
			let position = SCNVector3(randX, randY, randZ)
			let wait = SCNAction.wait(duration: 2)
			let move = SCNAction.move(to: position, duration: 0.5)
			let sequsence = SCNAction.sequence([wait, move])
			stone.runAction(sequsence)
			stone.physicsBody = .dynamic()
		}
	}
	
	/// Удаление белых камней, имеющие координаты points
	private func deleteWhiteStones(points: (Point, Point)) {
		var points = self.whiteStonesOnBoard.filter( {$0.1 == points.0 || $0.1 == points.1} )
		let stones = points.map( {$0.0} )
		deleteStones(stones: stones)
		points[0].1 = nil
		points[1].1 = nil
		self.whiteStonesOnFloor = points + self.whiteStonesOnFloor
	}
	
	/// Удаление черных камней, имеющие координаты points
	private func deleteBlackStones(points: (Point, Point)) {
		var points = self.blackStonesOnBoard.filter( {$0.1 == points.0 || $0.1 == points.1} )
		let stones = points.map( {$0.0} )
		deleteStones(stones: stones)
		points[0].1 = nil
		points[1].1 = nil
		self.blackStonesOnBoard = points + self.blackStonesOnBoard
	}
	
	/// Передвижение в указанную позицию белогого камня
	private func moveWhiteStone(point: Point) {
		guard var whiteStone = self.whiteStonesOnFloor.popLast() else { return }
		moveStone(point: point, stone: whiteStone.0)
		whiteStone.1 = point
		self.whiteStonesOnBoard.append(whiteStone)
	}
	
	/// Передвижение в указанную позицию черного камня
	private func moveBlackStone(point: Point) {
		guard var blackStone = self.blackStonesOnFloor.popLast() else { return }
		moveStone(point: point, stone: blackStone.0)
		blackStone.1 = point
		self.blackStonesOnBoard.append(blackStone)
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
			guard let name = node.name else { return }
			if name == "exit" {
				exitScene()
			}
			if name != self.namePin { return }
			print(node.position, name)
			let point = Point(Int(node.position.x), Int(node.position.z))
			self.gomoku.nextMove(point: point)
			//let color: NSColor
//			if !self.gomoku.movePalyer(point: point) {
//				color = .red
//			} else {
//				color = .green
//				self.gomoku.moveAI()
//			}
//			if self.board.placeStone(point: point, stone: stone) {
//				if stone == .white {
//					moveWhiteStone(position: node.position)
//				} else {
//					moveBlackStone(position: node.position)
//				}
//				if let poinst = self.board.captures(point: point, stone: stone) {
//					deleteStones(points: poinst)
//				}
//			}
//			self.board.printBourd()
            
        }
    }
}

extension GameViewController: MoveProtocol {
	/// Удаление пара комней с доски в результате захвата.
	func delete(points: (Point, Point), stone: Stone) {
		switch stone {
		case .white:
			deleteWhiteStones(points: points)
		case .black:
			deleteBlackStones(points: points)
		}
		//deleteStones(points: points)
	}
	
	/// Перемещение камня в указанную точку
	func moving(point: Point, stone: Stone) {
		switch stone {
		case .white:
			moveWhiteStone(point: point)
		case .black:
			moveBlackStone(point: point)
		}
	}
	
	/// Подсветка pin указанным цветом.
	func pinShine(point: Point, color: NSColor) {
		let position = SCNVector3(Double(point.x), self.y, Double(point.y))
		guard let node = self.scene.rootNode.childNodes.first(where: {
			$0.name == self.namePin &&
			$0.position == position}) else { return }
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

extension SCNVector3 {
	static func == (left: SCNVector3, right: SCNVector3) -> Bool {
		return left.x == right.x && left.y == right.y && left.z == right.z
	}
}

/*

//		let board = scene.rootNode.childNode(withName: "board", recursively: true)!
//		let material = SCNMaterial()
//		material.diffuse.contents = NSColor.black
//		material.normal.contents = NSImage(named: "board2")
//		material.shininess = 1
//		board.geometry?.materials.append(material)
//
//		self.scene.rootNode.addChildNode(board)
override func viewDidLoad() {
	super.viewDidLoad()
	
	// create a new scene
	let scene = SCNScene(named: "art.scnassets/ship.scn")!
	
	// create and add a camera to the scene
	let cameraNode = SCNNode()
	cameraNode.camera = SCNCamera()
	scene.rootNode.addChildNode(cameraNode)
	
	// place the camera
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
	
	// create and add a light to the scene
	let lightNode = SCNNode()
	lightNode.light = SCNLight()
	lightNode.light!.type = .omni
	lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
	scene.rootNode.addChildNode(lightNode)
	
	// create and add an ambient light to the scene
	let ambientLightNode = SCNNode()
	ambientLightNode.light = SCNLight()
	ambientLightNode.light!.type = .ambient
	ambientLightNode.light!.color = NSColor.darkGray
	scene.rootNode.addChildNode(ambientLightNode)
	
	// retrieve the ship node
	let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
	
	// animate the 3d object
	ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
	
	// retrieve the SCNView
	let scnView = self.view as! SCNView
	
	// set the scene to the view
	scnView.scene = scene
	
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

*/
