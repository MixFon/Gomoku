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
	private var mode = Mode.pvp
	
	// Поставить private
	var board = Board()
	
	weak var delegate: MoveProtocol?
	
	private var stone = Stone.white
	
	private var whiteCaptures: Int = 0
	private var blackCaptures: Int = 0
	
	let numberCapturesToWin: Int = 2
	
	var makeSnapshot: (()->NSImage?)?
	
	enum Mode: String {
		case pvp
		case pvc
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
				moveAI(point: point)
			} else {
				self.stone = self.stone.opposite()
			}
		} else {
			self.delegate?.pinShine(point: point, color: .red)
		}
	}
	
	/// Установка количества захвата. Вызвается во время загрухки сохраненной игры.
	func setCaptures(_ whiteCaptures: Int, _ blackCaptures: Int) {
		self.whiteCaptures = whiteCaptures
		self.blackCaptures = blackCaptures
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
	
	/// Ход ИИ
	private func moveAI(point: Point) {
		print("y = \(point.y + 9) x =\(point.x + 9)")
		
//		var i = 0
//		let stone = Stone.black
//		var point = Point(i - 9, i - 9)
//		while true {
//			point = Point(i - 9, i - 9)
//			if self.board.placeStone(point: point, stone: stone) {
//				break
//			}
//			i += 1
//		}
//		self.delegate?.moving(point: point, stone: stone)
//		capturesStones(point: point, stone: stone)
//		checkWinerToFiveStones(point: point, stone: stone)
	}
	
	/// Ход игрока
	private func movePalyer(point: Point, stone: Stone) -> Bool {
		if !self.board.placeStone(point: point, stone: stone) {
			return false
		}
		self.delegate?.moving(point: point, stone: stone)
		capturesStones(point: point, stone: stone)
		checkWinerToFiveStones(point: point, stone: stone)
		return true
	}
	
	/// Проверка победителя по выставлении 5 камней в ряд. В случае победы все сбрасывается
	private func checkWinerToFiveStones(point: Point, stone: Stone) {
		if self.board.checkWinerToFiveSpots(point: point, stone: stone) {
			self.delegate?.showingWinner(stone: stone)
			self.reset()
		}
	}
	
	/// Проверка победител по захвату. Для победы нужно провести 5 захватов
	private func checkWinerToCapture() {
		if self.whiteCaptures >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .white)
			reset()
		} else if self.blackCaptures >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .black)
			reset()
		}
	}
	
	/// Сбразыватеся до начальных настроек
	private func reset() {
		self.board.clearBoard()
		self.blackCaptures = 0
		self.whiteCaptures = 0
		self.stone = .white
		//self.ai?.task.interrupt()
		self.ai = AI()
	}
	
	/// Производит захват камней
	private func capturesStones(point: Point, stone: Stone) {
		if let poinst = self.board.captures(point: point, stone: stone) {
			if stone == .white {
				self.whiteCaptures += 1
			} else {
				self.blackCaptures += 1
			}
			self.delegate?.delete(points: poinst, stone: stone.opposite())
			checkWinerToCapture()
		}
	}
	
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
		return (self.whiteCaptures, self.blackCaptures)
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
