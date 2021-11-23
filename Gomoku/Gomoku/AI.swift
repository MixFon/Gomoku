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
		//var board = board
		let newLevel = level - 1
		if newLevel == 0 {
			return board.getBestWeithForCurrentSpot()
		}
		for bestPoint in board.getBestPoints() {
			// Возможно будет долго работать, поменять
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: bestPoint)
			let weight = miniMax(board: newBoard, level: newLevel)
			//print("weight", weight >> 8 & 0xff, weight & 0xff)
			//board.setWeightToPoint(point: bestPoint, weight: weight)
			board.setConstWeightToPoint(point: bestPoint, weight: weight)
		}
//		let weight = board.getBestWeithForCurrentSpot()
//		print("weight", weight >> 8 & 0xff, weight & 0xff)
		return board.getBestWeithForCurrentSpot()
	}
	
	func startMinimax(board: Board, bestPoints: [Point]) -> Point? {
		//let boardForMinimax = Board(board: board)
		let newBoard = Board(board: board)
		//let bestPoints = newBoard.getBestPoints()
		//let bestPoints = getStartBestPoints(board: board)
		var bestPoint: Point?
		var wieght: Board.Weight = 0
		print("bestPoints", bestPoints.count)
		print("currentSpot", board.currentSpot.rawValue)
		for point in bestPoints {
			let newBoard = Board(board: newBoard)
			newBoard.setCurrentSpotToPoint(point: point)
			//newBoard.setSpot(point: point, spot: board.currentSpot)
			let result = (miniMax(board: newBoard, level: self.startLevel)) & 0xff
			//print("result", result)
			if result > wieght {
				wieght = result
				bestPoint = point
			}
		}
		return bestPoint
	}
	
}
