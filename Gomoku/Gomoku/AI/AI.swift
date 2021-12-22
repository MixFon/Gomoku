//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	
	let mutex = NSLock()
	
	var startLevel = 6
	
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
		let newLevel = level - 1
		if newLevel == 0 {
			return board.getWeight(point: board.getBestPoint())
		}
		// Максимальный вес для текущего spot
		var maxWeight: Board.Weight = 0
        //print(board.getBestPoints().count)
		for bestPoint in board.getBestPoints() {
			if bestPoint.isNegativeCoordinates() { continue }
			// Возможно будет долго работать, поменять
			let newBoard = Board(board: board)
			newBoard.setCurrentSpotToPoint(point: bestPoint)
			let weight = miniMax(board: newBoard, level: newLevel)
			if let finishWeight = updateMaxWeight(spot: board.getCurrentSpot(),maxWeight: &maxWeight,weight: weight) {
				return finishWeight
			}
		}
		return maxWeight
	}
	
	func startMinimax(board: Board, allPoints: [Point]) -> Point? {
		printInfomation(board: board)
		board.printBourd()
		if let point = checkingMaxWeightPoint(board: board, points: allPoints) {
			return point
		}
		let group = DispatchGroup()
		var maxWeight: Board.Weight = 0
		var resultPoint = board.getBestPointBlack().point
		// Массив точек, в котороых проиходил расчет.
		var calculatedPoints = [Board.BestPoint]()
		//var points = board.getPointsCapturesBlackArray()
		//points.append(contentsOf: board.getBestPoints())
		//for point in points {
        //for point in board.getBestPoints() {
        //print("allPoints", allPoints.count)
        for point in allPoints {
			group.enter()
			DispatchQueue.global(qos: .userInteractive).async {
				let newPoint = point
				let weight = self.calculateWeightMiniMax(board: board, point: newPoint)
				self.mutex.lock()
				calculatedPoints.append(Board.BestPoint(point: newPoint, weight: weight))
				self.mutex.unlock()
				group.leave()
			}
		}
		group.wait()
		for best in calculatedPoints {
			if updateMaxPoint(spot: board.getCurrentSpot(), maxWeight: &maxWeight, weight: best.weight) {
				resultPoint = best.point
			}
		}
        let (w, b) = Board.getWeightWhiteBlack(weight: board.getWeight(point: resultPoint))
        print("resultPoint w, b ", w, b, resultPoint)
		return resultPoint
	}
	
	/// Расчет веса для точки в minimax
	private func calculateWeightMiniMax(board: Board, point: Point) -> Board.Weight {
		let board = Board(board: board)
		board.setCurrentSpotToPoint(point: point)
		let weight = miniMax(board: board, level: self.startLevel)
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
	private func printInfomation(board: Board) {
		let (bestWhite, b) = Board.getWeightWhiteBlack(weight: board.getBestPointWhite().weight)
		let (w, bestBlack) = Board.getWeightWhiteBlack(weight: board.getBestPointBlack().weight)
		print("bestPointWhite", bestWhite, b, board.getBestPointWhite().point)
		print("bestPointBlack", w, bestBlack, board.getBestPointBlack().point)
		let (w1, b1) = Board.getWeightWhiteBlack(weight: board.getBestWeigthForCurrentSpot())
		print("WeithForCurrentSpot w, b ", w1, b1, board.getBestPoint())
	}
	
	/// Проверяет нет ли для текущего камня максимального значения.
	private func checkingMaxWeightPoint(board: Board, points: [Point]) -> Point? {
		let maxPoints = points.filter( {
			let wheight = board.getWeight(point: $0)
			return checkMaxWeight(spot: board.getCurrentSpot(), weight: wheight) ||
				checkMaxWeight(spot: board.getCurrentSpot().opposite(), weight: wheight)
		} )
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
			return maxBlack
		} else if maxBlack == nil && maxWhite != nil {
			return maxWhite
		} else if maxBlack != nil && maxWhite != nil {
			let (_, maxB) = Board.getWeightWhiteBlack(weight: board.getWeight(point: maxBlack!))
			let (maxW, _) = Board.getWeightWhiteBlack(weight: board.getWeight(point: maxWhite!))
			if maxB >= maxW {
				return maxBlack
			} else {
				return maxWhite
			}
		}
		return nil
	}
}
