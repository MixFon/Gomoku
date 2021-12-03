//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	
	let mutex = NSLock()
	var bestPoints = [Board.BestPoint]()
	
	var startLevel = 10
	
	
	
	/// Обновление максимального веса. Если weight максимальный для текучего spot, то возвращаем его
	private func updateMaxPoint(spot: Board.Spot, maxWeight: inout Board.Weight, weight: Board.Weight) -> Bool {
		let (maxWhite, maxBlack) = Board.getWeightWhiteBlack(weight: maxWeight)
		let (white, black) = Board.getWeightWhiteBlack(weight: weight)
		switch spot {
		case .white:
			if white > maxWhite {
				maxWeight = weight
				return true
			}
		case .black:
			if black > maxBlack {
				maxWeight = weight
				return true
			}
		default:
			break
		}
		return false
	}
	
	/// Обновление максимального веса. Если weight максимальный для текучего spot, то возвращаем его
	private func updateMaxWeight(spot: Board.Spot, maxWeight: inout Board.Weight, weight: Board.Weight) -> Board.Weight? {
		let (maxWhite, maxBlack) = Board.getWeightWhiteBlack(weight: maxWeight)
		let (white, black) = Board.getWeightWhiteBlack(weight: weight)
		switch spot {
		case .white:
			if white > maxWhite { maxWeight = weight }
			if white >= 9 { return weight }
		case .black:
			if black > maxBlack { maxWeight = weight }
			if black >= 9 { return weight }
		default:
			break
		}
		return nil
	}
	
	/// Алгоритм MiniMax. Возвратить наилучший вес для противника
	func miniMax(board: Board, level: Int) -> Board.Weight {
		//print("level", level)
		let newLevel = level - 1
		if newLevel == 0 {
			return board.getWeight(point: board.getBestPoint())
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
		print("for best white:")
		let group = DispatchGroup()
		var maxWeight: Board.Weight = 0
		var resultPoint = resultBoard.bestPointWhite.point
		self.bestPoints = []
		var points = [Point](resultBoard.pointsCapturesBlack)
		points.append(contentsOf: resultBoard.getBestPoints())
		print(points)
		for point in points {
			group.enter()
			DispatchQueue.global(qos: .userInteractive).async {
				let newPoint = point
				let weight = self.forTest(resultBoard: resultBoard, point: newPoint)
				self.mutex.lock()
				self.bestPoints.append(Board.BestPoint(point: newPoint, weight: weight))
				self.mutex.unlock()
				group.leave()
			}
		}
		group.wait()
		for best in self.bestPoints {
			if updateMaxPoint(spot: board.currentSpot, maxWeight: &maxWeight, weight: best.weight) {
				resultPoint = best.point
			}
		}
		print("for best black:")
		return resultPoint
		//return resultBoard.getBestPoint()
	}
	
	private func setToWeightPoints(weight: Board.Weight) {
	
	}
	
	func forTest(resultBoard: Board, point: Point) -> Board.Weight {
		let board = Board(board: resultBoard)
		board.setCurrentSpotToPoint(point: point)
		let weight = miniMax(board: board, level: self.startLevel)
		let (w, b) = Board.getWeightWhiteBlack(weight: weight)
		print("return", w, b, point)
		return weight
	}
	
	/// Проверяет получено ли максимальное значение для указанного spot
	private func checkMaxWeight(spot: Board.Spot, weight: Board.Weight) -> Bool {
		let (white, black) = Board.getWeightWhiteBlack(weight: weight)
		let finishWeight = 9
		switch spot {
		case .black:
			return black >= finishWeight
		case .white:
			return white >= finishWeight
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
		print("WeithForCurrentSpot w, b ", w1, b1, board.getBestPoint())
	}
	
	/// Проверяет нет ли для текущего камня максимального значения.
	private func checkingMaxWeightPoint(board: Board, points: [Point]) -> Point? {
		let maxPoints = points.filter( {
			let wheight = board.getWeight(point: $0)
			return checkMaxWeight(spot: board.currentSpot, weight: wheight) ||
				checkMaxWeight(spot: board.currentSpot.opposite(), weight: wheight)
		} )
		print(maxPoints)
		let maxBlack = maxPoints.max(by: {
			let (_, oneB) = Board.getWeightWhiteBlack(weight: board.getWeight(point: $0))
			let (_, twoB) = Board.getWeightWhiteBlack(weight: board.getWeight(point: $1))
			return oneB < twoB
		})
		let maxWhite = maxPoints.max(by: {
			let (oneW, _) = Board.getWeightWhiteBlack(weight: board.getWeight(point: $0))
			let (twoW, _) = Board.getWeightWhiteBlack(weight: board.getWeight(point: $1))
			return oneW < twoW
		})
		if maxBlack == nil && maxWhite == nil {
			return nil
		} else if maxBlack != nil && maxWhite == nil {
			print("1 return maxBlack", maxBlack!)
			return maxBlack
		} else if maxBlack == nil && maxWhite != nil {
			print("2 return maxWhite", maxWhite!)
			return maxWhite
		} else if maxBlack != nil && maxWhite != nil {
			let (_, maxB) = Board.getWeightWhiteBlack(weight: board.getWeight(point: maxBlack!))
			let (maxW, _) = Board.getWeightWhiteBlack(weight: board.getWeight(point: maxWhite!))
			if maxB >= maxW {
				print("3 return maxBlack", maxBlack!)
				return maxBlack
			} else {
				print("4 return maxWhite", maxWhite!)
				return maxWhite
			}
		}
		print("return nil")
		fatalError()
		//return nil
		//print(temp)
		/*
		for point in points {
			let wheight = board.getWeight(point: point)
			if checkMaxWeight(spot: board.currentSpot.opposite(), weight: wheight) { return point }
			if checkMaxWeight(spot: board.currentSpot, weight: wheight) { return point }
		}
		return nil
		*/
	}
}
