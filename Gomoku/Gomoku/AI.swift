//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	
	var board = Board()
	
	var currentSpot = Board.Spot.black
	
	let maxLevel = 5
	
	/// Установка доски перед стартом расчета MiniMax
	func setBoard(board: Board) {
		self.board = Board(board: board)
	}
	
	/// Алгоритм MiniMax
	func miniMax(board: Board, level: Int) -> Board.Weight {
		
		let newLevel = level - 1
		if newLevel == self.maxLevel {
			return board.getBestWeithForCurrentSpot()
		}
		for bestPoint in board.getBestPoints() {
			// Возможно будет долго работать, поменять
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: bestPoint)
			let weight = miniMax(board: newBoard, level: newLevel)
			board.setWeightToPoint(point: bestPoint, weight: weight)
		}
		return board.getBestWeithForCurrentSpot()
	}
	
}
