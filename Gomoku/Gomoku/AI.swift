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
		//print("level", level)
		let newLevel = level - 1
		if newLevel == 0 {
			return board.getBestWeithForCurrentSpot()
		}
		for bestPoint in board.getBestPoints() {
			// Возможно будет долго работать, поменять
			let newBoard = Board(board: board)
			let temp = newBoard.getBestWeithForCurrentSpot()
			let (w, b) = Board.getWeightWhiteBlack(weight: temp)
			//print("w = \(w) b = \(b)")
			if w >= 10 || b >= 10 {
				print("level", level)
				let (w, b) = Board.getWeightWhiteBlack(weight: newBoard.getBestWeithForCurrentSpot())
				print("w, b ", w, b)
				return newBoard.getBestWeithForCurrentSpot()
			}
			newBoard.setCurrentSpotToPoint(point: bestPoint)
			let weight = miniMax(board: newBoard, level: newLevel)
			//board.setWeightToPoint(point: bestPoint, weight: weight)
			board.setConstWeightToPoint(point: bestPoint, weight: weight)
		}
		return board.getBestWeithForCurrentSpot()
	}
	
	func startMinimax(board: Board, bestPoints: [Point]) -> Point? {
		let resultBoard = Board(board: board)
		print("-----------")
		sdf
		// Написать функцию, которая не будет обновлять точку в которую нужно поставить,
		// если в нейнаходится вес выше, устанавливаемого.
		resultBoard.printBourd()
		print("bestPoints", bestPoints.count)
		print("currentSpot", board.currentSpot.rawValue)
		//for point in bestPoints {
		for point in board.getBestPoints() {
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: point)
			let result = miniMax(board: newBoard, level: self.startLevel)
			//resultBoard.setWeightToPoint(point: point, weight: result)
			resultBoard.setConstWeightToPoint(point: point, weight: result)
		}
		printBestWeight(board: resultBoard)
		resultBoard.printBourd()
		return resultBoard.getBestPoint()
	}
	
	private func printBestWeight(board: Board) {
		let (bestWhite, b) = Board.getWeightWhiteBlack(weight: board.bestPointWhite.weight)
		let (w, bestBlack) = Board.getWeightWhiteBlack(weight: board.bestPointBlack.weight)
		print("bestPointWhite", bestWhite, b)
		print("bestPointBlack", w, bestBlack)
		let (w1, b1) = Board.getWeightWhiteBlack(weight: board.getBestWeithForCurrentSpot())
		print("w, b ", w1, b1)
	}
}
