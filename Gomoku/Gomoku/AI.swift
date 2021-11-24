//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	
	var startLevel = 10
	
	/// Алгоритм MiniMax
	func miniMax(board: Board, level: Int) -> Board.Weight {
		let newLevel = level - 1
		if newLevel == 0 {
			return board.getBestWeithForCurrentSpot()
		}
		for bestPoint in board.getBestPoints() {
			// Возможно будет долго работать, поменять
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: bestPoint)
			let weight = miniMax(board: newBoard, level: newLevel)
			board.setConstWeightToPoint(point: bestPoint, weight: weight)
		}
		return board.getBestWeithForCurrentSpot()
	}
	
	func startMinimax(board: Board, bestPoints: [Point]) -> Point? {
//		var bestPoint: Point?
//		var wieght: Board.Weight = 0
		let resultBoard = Board(board: board)
		resultBoard.printBourd()
		print("bestPoints", bestPoints.count)
		print("currentSpot", board.currentSpot.rawValue)
		for point in bestPoints {
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: point)
			let result = miniMax(board: newBoard, level: self.startLevel)
			//resultBoard.setWeightToPoint(point: point, weight: result)
			resultBoard.setConstWeightToPoint(point: point, weight: result)
			//print("result", result)
//			if result > wieght {
//				wieght = result
//				bestPoint = point
//			}
		}
		resultBoard.printBourd()
		return resultBoard.getBestPoint()
	}
	
}
