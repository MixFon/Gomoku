//
//  Gomoku.swift
//  Gamoku
//
//  Created by Михаил Фокин on 19.10.2021.
//

import Foundation

class Gomoku {
	var mode = Mode.pvp
	private var board = Board()
	private var slone = Stone.white
	
	private var captureWhite: Int = 0
	private var captureBlack: Int = 0
	
	let numberCapturesToWin: Int = 2
	 
	weak var delegate: MoveProtocol?
	
	enum Mode {
		case pvp
		case pvc
	}
	
	/// Следующий ход. Может быть как ход PvP так и PvC. В зависимости от типа игры.
	func nextMove(point: Point) {
		if movePalyer(point: point, stone: self.slone) {
			self.delegate?.pinShine(point: point, color: .green)
			if self.mode == .pvc {
				moveAI()
			} else {
				self.slone = self.slone.opposite()
			}
		} else {
			self.delegate?.pinShine(point: point, color: .red)
		}
	}
	
	/// Ход ИИ
	private func moveAI() {
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
		if !self.board.placeStone(point: point, stone: slone) {
			return false
		}
		self.delegate?.moving(point: point, stone: slone)
		capturesStones(point: point, stone: slone)
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
