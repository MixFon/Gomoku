//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	
	//var currentSpot = Board.Spot.black
	
	var startLevel = 5
	
	/// Установка доски перед стартом расчета MiniMax
//	func setBoard(board: Board) {
//		self.board = Board(board: board)
//	}
	
	/// Алгоритм MiniMax
	func miniMax(board: Board, level: Int) -> Board.Weight {
		//print(level)
		let newLevel = level - 1
		if newLevel == 0 {
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
	
	func startMinimax(board: Board) -> Point {
		//let boardForMinimax = Board(board: board)
		let bestPoints = board.getBestPoints()
		var bestPoint: Point?
		var wieght: Board.Weight = 0
		print("bestPoints", bestPoints.count)
		print("currentSpot", board.currentSpot.rawValue)
		for point in bestPoints {
			let newBoard = Board(board: board)
			newBoard.setSpot(point: point, spot: board.currentSpot)
			let result = (miniMax(board: newBoard, level: self.startLevel) >> 8) & 0xff
			if result >= wieght {
				wieght = result
				bestPoint = point
			}
		}
		return bestPoint!
	}
	
}
