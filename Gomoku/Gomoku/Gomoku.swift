//
//  Gomoku.swift
//  Gamoku
//
//  Created by Михаил Фокин on 19.10.2021.
//

import Foundation

class Gomoku {
	var ai = try? AI()
	private var mode = Mode.pvp
	private var board = Board()
	private var stone = Stone.white
	
	private var captureWhite: Int = 0
	private var captureBlack: Int = 0
	
	let numberCapturesToWin: Int = 2
	 
	weak var delegate: MoveProtocol?
	
	enum Mode: String {
		case pvp
		case pvc
	}
	
	/// Вызывается при закрузке сохраненной игры. На доске устанавливаются нужные spots
	func setStartPointOnBouard(whitePoints: [Point], blackPoints: [Point]) {
		self.board.printBourd()
		self.board.setStartSpotsOnBouard(whitePoints: whitePoints, blackPoints: blackPoints)
		self.board.printBourd()
	}
	
	/// Следующий ход. Может быть как ход PvP так и PvC. В зависимости от типа игры.
	func nextMove(point: Point) {
		if movePalyer(point: point, stone: self.stone) {
			self.delegate?.pinShine(point: point, color: .green)
			if self.mode == .pvc {
				moveAI()
			} else {
				self.stone = self.stone.opposite()
			}
		} else {
			self.delegate?.pinShine(point: point, color: .red)
		}
	}
	
	/// Возвращает камень, который должен ходить следеющим
	func getCurrentStone() -> String {
		return String(self.stone.rawValue)
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
	
	/// Возвращает режим игры в виде строки
	func getCurrentMode() -> String {
		return self.mode.rawValue
	}
	
	/// Ход ИИ
	private func moveAI() {
		ai?.getRequestToAI(message: "temp\n")
		var i = 0
		let stone = Stone.black
		var point = Point(i - 9, i - 9)
		while true {
			point = Point(i - 9, i - 9)
			if self.board.placeStone(point: point, stone: stone) {
				break
			}
			i += 1
		}
		self.delegate?.moving(point: point, stone: stone)
		capturesStones(point: point, stone: stone)
		checkWinerToFiveStones(point: point, stone: stone)
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
			self.board.clearBoard()
		}
	}
	
	/// Проверка победител по захвату. Для победы нужно провести 5 захватов
	private func checkWinerToCapture() {
		if self.captureWhite >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .white)
			self.board.clearBoard()
		} else if self.captureBlack >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .black)
			self.board.clearBoard()
		}
	}
	
	/// Производит захват камней
	private func capturesStones(point: Point, stone: Stone) {
		if let poinst = self.board.captures(point: point, stone: stone) {
			if stone == .white {
				self.captureWhite += 1
			} else {
				self.captureBlack += 1
			}
			self.delegate?.delete(points: poinst, stone: stone.opposite())
			checkWinerToCapture()
		}
	}
}
