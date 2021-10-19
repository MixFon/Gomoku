//
//  Gomoku.swift
//  Gamoku
//
//  Created by Михаил Фокин on 19.10.2021.
//

import Foundation

class Gomoku {
	var board = Board()
	
	weak var delegate: MoveProtocol?
	
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
	func movePalyer(point: Point) -> Bool {
		let slone = Stone.white
		if !self.board.placeStone(point: point, stone: slone) {
			return false
		}
		self.delegate?.moving(point: point, stone: slone)
		capturesStones(point: point, stone: slone)
		return true
	}
	
	private func capturesStones(point: Point, stone: Stone) {
		if let poinst = self.board.captures(point: point, stone: stone) {
			self.delegate?.delete(points: poinst)
		}
	}
}
