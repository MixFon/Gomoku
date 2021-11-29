//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	
	var startLevel = 5
	
	/// Обновление максимального веса. Если weight максимальный для текучего spot, то возвращаем его
	private func updateMaxWeight(spot: Board.Spot, maxWeight: inout Board.Weight, weight: Board.Weight) -> Board.Weight? {
		let (maxWhite, maxBlack) = Board.getWeightWhiteBlack(weight: maxWeight)
		let (white, black) = Board.getWeightWhiteBlack(weight: weight)
		switch spot {
		case .white:
			if white > maxWhite { maxWeight = weight }
			if white >= 10 { return weight }
		case .black:
			if black > maxBlack { maxWeight = weight }
			if black >= 10 { return weight }
		default:
			break
		}
		return nil
	}
	
	/// Алгоритм MiniMax
	func miniMax(board: Board, level: Int) -> Board.Weight {
		//print("level", level)
		let newLevel = level - 1
		if newLevel == 0 {
			return board.getBestWeigthForCurrentSpot()
		}
		/// Максимальный вес для текущего spot
		var maxWeight: Board.Weight = 0
		for bestPoint in board.getBestPoints() {
			if bestPoint.isNegativeCoordinates() { print("continue"); continue }
			// Возможно будет долго работать, поменять
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: bestPoint)
			let weight = miniMax(board: newBoard, level: newLevel)
			if let finishWeight = updateMaxWeight(spot: board.currentSpot, maxWeight: &maxWeight, weight: weight) {
				return finishWeight
			}
		}
		return maxWeight
	}
	
	func startMinimax(board: Board, bestPoints: [Point]) -> Point? {
		let resultBoard = Board(board: board)
		print("-----------")
		printBestWeight(board: resultBoard)
		resultBoard.printBourd()
		if let point = checkingMaxWeightPoint(board: board, points: bestPoints) {
			return point
		}
		print("bestPoints", bestPoints.count)
		print("currentSpot", board.currentSpot.rawValue)
		/// Точка с максимальным весом для текущего spot
		var maxPoint = Point(-1, -1)
		/// Максимальный вес для текущего spot
		var maxWeight: Board.Weight = 0
		//for point in bestPoints {
//		for point in board.getBestPoints() {
//			let newBoard = Board(board: board)
//			newBoard.setCurrentSpotToPoint(point: point)
//			let result = miniMax(board: newBoard, level: self.startLevel)
//			if updateMaxWeight(spot: board.currentSpot, maxWeight: &maxWeight, weight: result) != nil {
//				let (w, b) = Board.getWeightWhiteBlack(weight: result)
//				print("!!!!!maxWeight w b", w, b, point)
//				//return point
//			} else {
//				maxPoint = point
//			}
//			let (w, b) = Board.getWeightWhiteBlack(weight: maxWeight)
//			print("maxWeight w b", w, b, maxPoint)
//			//if checkMaxWeight(spot: board.currentSpot, weight: result) { return point }
//			//resultBoard.setWeightToPoint(point: point, weight: result)
//			// Подумать над этим!!!!
//			//resultBoard.setConstWeightToPoint(point: point, weight: result)
//		}
		
		printBestWeight(board: resultBoard)
		resultBoard.printBourd()
		//return maxPoint
		return resultBoard.getBestPoint()
	}
	
	/// Проверяет получено ли максимальное значение для указанного spot
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
		print("bestPointWhite", bestWhite, b, board.bestPointWhite.point)
		print("bestPointBlack", w, bestBlack, board.bestPointBlack.point)
		let (w1, b1) = Board.getWeightWhiteBlack(weight: board.getBestWeigthForCurrentSpot())
		print("WeithForCurrentSpot w, b ", w1, b1)
	}
	
	/// Проверяет нет ли для текущего камня максимального значения.
	private func checkingMaxWeightPoint(board: Board, points: [Point]) -> Point? {
		for point in points {
			let wheight = board.getWeight(point: point)
			if checkMaxWeight(spot: board.currentSpot.opposite(), weight: wheight) { return point }
			if checkMaxWeight(spot: board.currentSpot, weight: wheight) { return point }
		}
		return nil
	}
}
