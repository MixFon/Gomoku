//
//  Gomoku.swift
//  Gamoku
//
//  Created by Михаил Фокин on 19.10.2021.
//

import Foundation

class Gomoku {
	var mode = Mode.pvp
	var board = Board()
	var slone = Stone.white
	
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
	func moveAI() {
		var i = 0
		let slone = Stone.black
		var point = Point(i - 9, i - 9)
		while true {
			point = Point(i - 9, i - 9)
			if self.board.placeStone(point: point, stone: slone) {
				break
			}
			i += 1
		}
		self.delegate?.moving(point: point, stone: slone)
		capturesStones(point: point, stone: slone)
	}
	
	/// Ход игрока
	func movePalyer(point: Point, stone: Stone) -> Bool {
		//let slone = Stone.white
		if !self.board.placeStone(point: point, stone: slone) {
			return false
		}
		self.delegate?.moving(point: point, stone: slone)
		capturesStones(point: point, stone: slone)
		return true
	}
	
	/// Производит захват камней
	private func capturesStones(point: Point, stone: Stone) {
		if let poinst = self.board.captures(point: point, stone: stone) {
			self.delegate?.delete(points: poinst, stone: stone.opposite())
		}
	}
}
