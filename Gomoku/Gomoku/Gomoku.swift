//
//  Gomoku.swift
//  Gamoku
//
//  Created by Михаил Фокин on 19.10.2021.
//

import Foundation
import AppKit

class Gomoku {
	var ai = AI()
	//var pythonAI = try? PythonAI()
	
	private var mode = Mode.pvp
	
	// Поставить private
	var board = Board()
	
	weak var delegate: MoveProtocol?
	
	private var stone = Stone.white
	
	private var winningPoint: WinningPoint?
	
//	private var whiteCaptures: Int = 0
//	private var blackCaptures: Int = 0
	
	let numberCapturesToWin: Int = 5
	
	var makeSnapshot: (()->NSImage?)?
	
	enum Mode: String {
		case pvp
		case pvc
	}
	
	/// Точка при которой образуется победитель. Целостность 5-ти камней не должна быть нарушна следующим ходом.
	private struct WinningPoint {
		let point: Point
		let stone: Stone
	}
	
	/// Вызывается при закрузке сохраненной игры. На доске устанавливаются нужные spots
	func setStartPointOnBouard(whitePoints: [Point], blackPoints: [Point]) {
		self.board.printBourd()
		self.board.clearBoard()
		self.board.setStartSpotsOnBouard(whitePoints: whitePoints, blackPoints: blackPoints)
		self.board.printBourd()
	}
	
	/// Следующий ход. Может быть как ход PvP так и PvC. В зависимости от типа игры.
	func nextMove(point: Point) {
		if movePalyer(point: point, stone: self.stone) {
			self.delegate?.pinShine(point: point, color: .green)
			if self.mode == .pvc {
				moveAI()
				//movePythonAI(point: point)
			} else {
				self.stone = self.stone.opposite()
			}
		} else {
			self.delegate?.pinShine(point: point, color: .red)
		}
	}
	
	/// Установка количества захвата. Вызвается во время загрухки сохраненной игры.
	func setCaptures(_ whiteCaptures: Int, _ blackCaptures: Int) {
		self.board.whiteCaptures = whiteCaptures
		self.board.blackCaptures = blackCaptures
//		self.whiteCaptures = whiteCaptures
//		self.blackCaptures = blackCaptures
	}
	
	/// Возвращает камень, который должен ходить следеющим
	func setCurrentStone(stone: String) {
		if let stone = Stone(rawValue: Character(stone)) {
			self.stone = stone
		}
	}
	
	/// Установка режима игры
	func setMode(mode: Mode) {
		self.mode = mode
	}
	
	/// Ход AI на python
	private func movePythonAI(point: Point) {
//		guard let ai = self.pythonAI else { print("error pythonAI"); return }
//		let point = self.board.convertCoordinateToBoard(point: point)
//		print(point)
//		ai.getRequestToAI(message: "\(point.y) \(point.x)")
	}
	
	/// Ход ИИ
	private func moveAI() {
		let bestPoints = getStartBestBlackPoints(board: self.board)
		if bestPoints.isEmpty { return }
		let start = DispatchTime.now()
		guard let point = ai.startMinimax(board: self.board, bestPoints: bestPoints) else { return }
		let end = DispatchTime.now()
		let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
		let timeInterval = Double(nanoTime) / 1_000_000_000
		self.delegate?.showTime(time: "\(timeInterval)")
		self.board.setCurrentSpotToPoint(point: point)
		//self.board.setSpot(point: point, spot: .black)
		let globalPoint = self.board.convertCoordinateToGlobal(point: point)
		self.delegate?.moving(point: globalPoint, stone: .black)
		//capturesStones(point: point, stone: stone)
		checkWinerToFiveStones(point: globalPoint, stone: .black)
		checkWinerToCapture()
		self.board.printBourd()
	}
	
	/// Возвращает массив лучших черных точек для доски
	private func getStartBestBlackPoints(board: Board) -> [Point] {
		var bestBlackPoints = [Point]()
		for (i, line) in board.board.enumerated() {
			for (j, element) in line.enumerated() {
				if element != 0x0 && element != 0x1 && element != 0x100 {
					bestBlackPoints.append(Point(i, j))
				}
			}
		}
		bestBlackPoints.sort(by: {
								let (_ , b1) = Board.getWeightWhiteBlack(weight: board.board[$0.x][$0.y])
								let (_ , b2) = Board.getWeightWhiteBlack(weight: board.board[$1.x][$1.y])
								return b1 > b2 }
		)
		if bestBlackPoints.isEmpty { return [] }
		return Array(bestBlackPoints[0...])
	}
	
	/// Ход игрока
	private func movePalyer(point: Point, stone: Stone) -> Bool {
		if !self.board.placeStone(point: point, stone: stone) {
			return false
		}
		self.delegate?.moving(point: point, stone: stone)
		//capturesStones(point: point, stone: stone)
		checkWinerToFiveStones(point: point, stone: stone)
		//self.board.printBourd()
		return true
	}
	
	/// Проверка победителя по выставлении 5 камней в ряд. В случае победы все сбрасывается.
	/// Игрок выставивший 5 камней подряд побеждает только когда следующийм ходом нельзя нарушить целостность 5 камней.
	private func checkWinerToFiveStones(point: Point, stone: Stone) {
		if let winnigPoint = self.winningPoint {
			if self.board.checkWinerToFiveSpots(point: winnigPoint.point, stone: winnigPoint.stone) {
				self.delegate?.showingWinner(stone: winnigPoint.stone)
				self.reset()
			} else {
				self.winningPoint = nil
			}
		} else if self.board.checkWinerToFiveSpots(point: point, stone: stone) {
			self.winningPoint = WinningPoint(point: point, stone: stone)
		}
	}
	
	/// Проверка победител по захвату. Для победы нужно провести 5 захватов
	private func checkWinerToCapture() {
		if self.board.whiteCaptures >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .white)
			print("Win Captures!!!!")
			reset()
		} else if self.board.blackCaptures >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .black)
			print("Win Captures!!!!")
			reset()
		}
	}
	
	/// Сбразыватеся до начальных настроек
	private func reset() {
		//self.board.clearBoard()
		self.winningPoint = nil
		self.board = Board()
		self.board.delegate = self.delegate
		self.stone = .white
		//self.ai?.task.interrupt()
		self.ai = AI()
	}
	
	/// Производит захват камней
//	private func capturesStones(point: Point, stone: Stone) {
//		if let poinst = self.board.captures(point: point, stone: stone) {
//			if stone == .white {
//				self.whiteCaptures += 1
//			} else {
//				self.blackCaptures += 1
//			}
//			self.delegate?.delete(points: poinst, stone: stone.opposite())
//			checkWinerToCapture()
//		}
//	}
	
	/// Сохранение состояния доски и сохранение изображения
	func saving() {
		let saveManager = SaveManager()
		saveManager.delegate = self
		saveManager.saving()
	}
}

// MARK: GetProtocol
extension Gomoku: GetProtocol {
	
	/// Возвращает кортеж количества захватов. Первыми идут белые
	func getCaptures() -> (Int, Int) {
		return (self.board.whiteCaptures, self.board.blackCaptures)
	}
	
	/// Возвращает кортеж массивов координат камней. Первым идут белые, вторым идут черные
	func getPoints() -> ([Point], [Point]) {
		return board.getWhiteBlackPointsSpot()
	}
	
	/// Возвращает камень, который должен ходить следеющим
	func getStone() -> String {
		return String(self.stone.rawValue)
	}
	
	/// Возвращает текущий режим игры
	func getMode() -> String {
		return self.mode.rawValue
	}
	
	/// Возвращает моментальный снимок экрана
	func getSnapshop() -> NSImage? {
		return self.makeSnapshot?()
	}
}
