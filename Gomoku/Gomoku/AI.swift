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
//			let temp = newBoard.getBestWeithForCurrentSpot()
//			let (w, b) = Board.getWeightWhiteBlack(weight: temp)
//			//print("w = \(w) b = \(b)")
//			if w >= 10 || b >= 10 {
//				print("level", level)
//				let (w, b) = Board.getWeightWhiteBlack(weight: newBoard.getBestWeithForCurrentSpot())
//				print("w, b ", w, b)
//				return newBoard.getBestWeithForCurrentSpot()
//			}
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
		resultBoard.printBourd()
		if let point = checkingMaxWeightPoint(board: board, points: bestPoints) {
			return point
		}
		print("bestPoints", bestPoints.count)
		print("currentSpot", board.currentSpot.rawValue)
		//for point in bestPoints {
		for point in board.getBestPoints() {
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: point)
			let result = miniMax(board: newBoard, level: self.startLevel)
			//if checkMaxWeight(spot: board.currentSpot, weight: result) { return point }
			resultBoard.setWeightToPoint(point: point, weight: result)
			//resultBoard.setConstWeightToPoint(point: point, weight: result)
			if let point = checkingMaxWeightPoint(board: board, points: bestPoints) {
				return point
			}
		}
		printBestWeight(board: resultBoard)
		resultBoard.printBourd()
		return resultBoard.getBestPoint()
	}
	
	/// Проверяет поличено ли максимальное значение для указанного spot
	private func checkMaxWeight(spot: Board.Spot, weight: Board.Weight) -> Bool {
		let (white, black) = Board.getWeightWhiteBlack(weight: weight)
		switch spot {
		case .black:
			return black >= 10
		case .white:
			return white >= 10
		default:
			return false
		}
	}
	
	/// Печать вспомогательной информации.
	private func printBestWeight(board: Board) {
		let (bestWhite, b) = Board.getWeightWhiteBlack(weight: board.bestPointWhite.weight)
		let (w, bestBlack) = Board.getWeightWhiteBlack(weight: board.bestPointBlack.weight)
		print("bestPointWhite", bestWhite, b)
		print("bestPointBlack", w, bestBlack)
		let (w1, b1) = Board.getWeightWhiteBlack(weight: board.getBestWeithForCurrentSpot())
		print("w, b ", w1, b1)
	}
	
	/// Проверяет нет ли для текущего камня максимального значения.
	private func checkingMaxWeightPoint(board: Board, points: [Point]) -> Point? {
		for point in points {
			if checkMaxWeight(spot: board.currentSpot, weight: board.getWeight(point: point)) {
				return point
			}
		}
		return nil
	}
}
