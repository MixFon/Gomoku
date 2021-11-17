//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	var task = Process()
	let inputPipe = Pipe()
	let outputPipe = Pipe()
	
	private var cheackBoard = Board()
	
	weak var delegate: MoveProtocol?
	
	private let pathonPath = "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3"
	private let scriptAIPath = "/Library/Frameworks/Python.framework/Versions/3.7/bin/AI/gomoku.py"
	private let flagAI = "1"
	
	struct Cell {
		let point: Point
		let spot: Board.Spot
		let weight: Int
	}
	
	init() throws {
		self.task.executableURL = URL(fileURLWithPath: self.pathonPath)
		self.task.arguments = [self.scriptAIPath, self.flagAI]
		self.task.standardInput = self.inputPipe
		
		self.task.standardOutput = self.outputPipe
		self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
		  
		NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: self.outputPipe.fileHandleForReading , queue: nil) { notification in
			
			let outputData = self.outputPipe.fileHandleForReading.availableData
			guard let outputString = String(data: outputData, encoding: .utf8) else { return }
			
			//print(outputString, "AI")
			if let first = outputString.first {
				//print(first)
				if first == "B" || first == "W" {
					let sendString = self.parseOutPutString(outputString: outputString)
					self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
					DispatchQueue.main.async(execute: {
						self.getRequestToAI(message: sendString + "\n")
					})
					return
				} else if first == "T" {
					let array = outputString.dropLast().split(separator: " ")
					DispatchQueue.main.async(execute: {
						self.delegate?.showTime(time: String(array[1]))
						let point = Point(Int(array[3])! - 9, Int(array[2])! - 9)
						self.delegate?.moving(point: point, stone: .black)
//						capturesStones(point: point, stone: .black)
//						checkWinerToFiveStones(point: point, stone: stone)
					})
					
				}
			}
			if outputString.isEmpty {
				return
			}
			
			DispatchQueue.main.async(execute: {
				// какие-то действия с UI в главном потоке.
			})
			self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
		}
		try self.task.run()
	}
	
	private func parseOutPutString(outputString: String) -> String {
		let arrayCell = outputString.split(separator: ";")
		var cellForCheck = [Cell]()
		var occupiedCells = [Cell]()
		let checkSpot = Board.Spot(rawValue: String(arrayCell[0]).first!)!
		for cellString in arrayCell[1...] {
			if cellString == "\n" { continue }
			let cell = cellString.split(separator: ":")
			//print("cell", cell)
			var pointsString = cell[0].split(separator: ",")
			//print("pointsString", pointsString)
			// Первым идет координата y потом x
			let point = Point(Int(pointsString[1])!, Int(pointsString[0])!)
			pointsString = cell[1].split(separator: ",")
			let spot: Board.Spot
			switch pointsString[0] {
			case ".":
				spot = .empty
			case "-1":
				spot = .black
			case "1":
				spot = .white
			default:
				spot = .empty
			}
			let weigth = Int(pointsString[1])!
			if spot == .empty {
				cellForCheck.append(Cell(point: point, spot: spot, weight: weigth))
			} else {
				occupiedCells.append(Cell(point: point, spot: spot, weight: weigth))
				self.cheackBoard.setSpot(point: point, spot: spot)
			}
		}
		
		var forSend = cellForCheck.filter( { self.cheackBoard.checkDoubleThree(point: $0.point,spot:checkSpot)} )
		forSend.sort(by: { $0.weight < $1.weight })
		var stringSend = ""
		for element in forSend[...2] {
			stringSend += "\(element.point.y),\(element.point.x);"
		}
		//print("send", stringSend)
		return stringSend
	}
	
	/// Отправляет запрос дочернему процессу в стандартный поток ввода.
	func getRequestToAI(message: String) {
		if let data = message.data(using: .utf8) {
			self.inputPipe.fileHandleForWriting.write(data)
		}
	}
}
