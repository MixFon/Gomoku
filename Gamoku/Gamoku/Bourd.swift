//
//  Bourd.swift
//  Gamoku
//
//  Created by Михаил Фокин on 15.10.2021.
//

import Foundation

enum Stone: Character {
	case white = "W"
	case black = "B"
}

struct Point {
	var x = 0
	var y = 0
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}

class Board {
	
	var board = Array(repeating: Array(repeating: Spot.empty, count: 19), count: 19)
	
	func printBourd() {
		for line in board {
			for elem in line {
				print(elem.rawValue, terminator: " ")
			}
			print()
		}
	}
	
	enum Spot: Character {
		case white = "W"
		case black = "B"
		case empty = "."
		
		func opposite() -> Spot {
			switch self {
			case .black:
				return .white
			case .white:
				return .black
			case .empty:
				return .empty
			}
		}
	}
	
	/// Установка камня нужного цвета в указанную координату.
	func placeStone(point: Point, stone: Stone) -> Bool {
		if !checkSpotCoordinate(point, .empty) {
			return false
		}
		guard let spot = Spot(rawValue: stone.rawValue) else { return false }
		if !checkDoubleThree(point: point, spot: spot) {
			return false
		}
		if !checkCaptures(point: point, spot: spot) {
			return false
		}
		setSpot(point: point, spot: spot)
		return true
	}
	
	/// Проверка захвата. Если захват возможен возвращает коршеж точек камней которые нужно удалить с доски.
	func captures(point: Point, stone: Stone) -> (Point, Point)? {
		guard let spot = Spot(rawValue: stone.rawValue) else { return nil }
		guard let points = isCaptures(point: point, spot: spot) else { return nil }
		print(points)
		deleteSpot(points: points)
		return points
	}
	
	/// Удаляет споты в указанных координатах
	private func deleteSpot(points: (Point, Point)) {
		self.board[points.0.x][points.0.y] = .empty
		self.board[points.1.x][points.1.y] = .empty
	}
	
	/// Проверяет позможен ли захват вражеских камней
	private func isCaptures(point: Point, spot: Spot) -> (Point, Point)? {
		let opposite = spot.opposite()
		let x = point.x
		let y = point.y
		if checkSpotCoordinate(Point(x - 3, y), spot) &&
			checkSpotCoordinate(Point(x - 2, y), opposite) &&
			checkSpotCoordinate(Point(x - 1, y), opposite) {
			return (Point(x - 2, y), Point(x - 1, y))
		}
		if checkSpotCoordinate(Point(x - 3, y + 3), spot) &&
			checkSpotCoordinate(Point(x - 2, y + 2), opposite) &&
			checkSpotCoordinate(Point(x - 1, y + 1), opposite) {
			return (Point(x - 2, y + 2), Point(x - 1, y + 1))
		}
		if checkSpotCoordinate(Point(x, y + 3), spot) &&
			checkSpotCoordinate(Point(x, y + 2), opposite) &&
			checkSpotCoordinate(Point(x, y + 1), opposite) {
			return (Point(x, y + 2), Point(x, y + 1))
		}
		if checkSpotCoordinate(Point(x + 3, y + 3), spot) &&
			checkSpotCoordinate(Point(x + 2, y + 2), opposite) &&
			checkSpotCoordinate(Point(x + 1, y + 1), opposite) {
			return (Point(x + 2, y + 2), Point(x + 1, y + 1))
		}
		if checkSpotCoordinate(Point(x + 3, y), spot) &&
			checkSpotCoordinate(Point(x + 2, y), opposite) &&
			checkSpotCoordinate(Point(x + 1, y), opposite) {
			return (Point(x + 2, y), Point(x + 1, y))
		}
		if checkSpotCoordinate(Point(x + 3, y - 3), spot) &&
			checkSpotCoordinate(Point(x + 2, y - 2), opposite) &&
			checkSpotCoordinate(Point(x + 1, y - 1), opposite) {
			return (Point(x + 2, y - 2), Point(x + 1, y - 1))
		}
		if checkSpotCoordinate(Point(x, y - 3), spot) &&
			checkSpotCoordinate(Point(x, y - 2), opposite) &&
			checkSpotCoordinate(Point(x, y - 1), opposite) {
			return (Point(x, y - 2), Point(x, y - 1))
		}
		if checkSpotCoordinate(Point(x - 3, y - 3), spot) &&
			checkSpotCoordinate(Point(x - 2, y - 2), opposite) &&
			checkSpotCoordinate(Point(x - 1, y - 1), opposite) {
			return (Point(x - 2, y - 2), Point(x - 1, y - 1))
		}
		print("nil")
		return nil
	}
	
	/// Установка спота нужного цвета
	private func setSpot(point: Point, spot: Spot) {
		self.board[point.x][point.y] = spot
	}
	
	/// Проверяет нахождение коорлинаты на доске. true если координата не входит на доску
	private func inBoard(point: Point) -> Bool {
		return (point.x < 0 || point.x >= 19 || point.y < 0 || point.y >= 19)
	}
	
	/// Проверка на то что в координате находится установленный спот
	private func checkSpotCoordinate(_ point: Point, _ spot: Spot) -> Bool {
		if inBoard(point: point) {
			return false
		}
		return self.board[point.x][point.y] == spot
	}
	
	/// Проверка положения перехода в захват
	private func checkCaptures(point: Point, spot: Spot) -> Bool {
		let opposite = spot.opposite()
		let x = point.x
		let y = point.y
		if checkSpotCoordinate(Point(x - 2, y), opposite) &&
			checkSpotCoordinate(Point(x - 1, y), spot) &&
			checkSpotCoordinate(Point(x + 1, y), opposite) {
			return false
		}
		if checkSpotCoordinate(Point(x - 2, y + 2), opposite) &&
			checkSpotCoordinate(Point(x - 1, y + 1), spot) &&
			checkSpotCoordinate(Point(x + 1, y - 1), opposite) {
			return false
		}
		if checkSpotCoordinate(Point(x, y + 2), opposite) &&
			checkSpotCoordinate(Point(x, y + 1), spot) &&
			checkSpotCoordinate(Point(x, y - 1), opposite) {
			return false
		}
		if checkSpotCoordinate(Point(x + 2, y + 2), opposite) &&
			checkSpotCoordinate(Point(x + 1, y + 1), spot) &&
			checkSpotCoordinate(Point(x - 1, y - 1), opposite) {
			return false
		}
		if checkSpotCoordinate(Point(x + 2, y), opposite) &&
			checkSpotCoordinate(Point(x + 1, y), spot) &&
			checkSpotCoordinate(Point(x - 1, y), opposite) {
			return false
		}
		if checkSpotCoordinate(Point(x + 2, y - 2), opposite) &&
			checkSpotCoordinate(Point(x + 1, y - 1), spot) &&
			checkSpotCoordinate(Point(x - 1, y + 1), opposite) {
			return false
		}
		if checkSpotCoordinate(Point(x, y - 2), opposite) &&
			checkSpotCoordinate(Point(x, y - 1), spot) &&
			checkSpotCoordinate(Point(x, y + 1), opposite) {
			return false
		}
		if checkSpotCoordinate(Point(x - 2, y - 2), opposite) &&
			checkSpotCoordinate(Point(x - 1, y - 1), spot) &&
			checkSpotCoordinate(Point(x + 1, y + 1), opposite) {
			return false
		}
		return true
	}
	
	/// Проверка наличия двойной троки
	private func checkDoubleThree(point: Point, spot: Spot) -> Bool {
		var count = 0
		if doubleThreeOne(point: point, spot: spot) {
			count += 1
		}
		if doubleThreeTwo(point: point, spot: spot) {
			count += 1
		}
		if doubleThreeThree(point: point, spot: spot) {
			count += 1
		}
		if doubleThreeFour(point: point, spot: spot) {
			count += 1
		}
		if doubleThreeFive(point: point, spot: spot) {
			count += 1
		}
		if doubleThreeSix(point: point, spot: spot) {
			count += 1
		}
		if doubleThreeSeven(point: point, spot: spot) {
			count += 1
		}
		if doubleThreeEight(point: point, spot: spot) {
			count += 1
		}
		print("count =", count)
		return count < 2
	}
	
	// #x#
	// #o#
	// ###
	private func doubleThreeOne(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x - 3, point.y), spot) &&
			checkSpotCoordinate(Point(point.x - 2, point.y), spot) &&
			checkSpotCoordinate(Point(point.x - 1, point.y), .empty)
		two =
			checkSpotCoordinate(Point(point.x - 2, point.y), spot) &&
			checkSpotCoordinate(Point(point.x - 1, point.y), spot)
		return one || two
	}
	
	// ##x
	// #o#
	// ###
	private func doubleThreeTwo(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x - 3, point.y + 3), spot) &&
			checkSpotCoordinate(Point(point.x - 2, point.y + 2), spot) &&
			checkSpotCoordinate(Point(point.x - 1, point.y + 1), .empty)
		two =
			checkSpotCoordinate(Point(point.x - 2, point.y + 2), spot) &&
			checkSpotCoordinate(Point(point.x - 1, point.y + 1), spot)
		return one || two
	}
	
	// ###
	// #ox
	// ###
	private func doubleThreeThree(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x, point.y + 3), spot) &&
			checkSpotCoordinate(Point(point.x, point.y + 2), spot) &&
			checkSpotCoordinate(Point(point.x, point.y + 1), .empty)
		two =
			checkSpotCoordinate(Point(point.x, point.y + 2), spot) &&
			checkSpotCoordinate(Point(point.x, point.y + 1), spot)
		return one || two
	}
	
	// ###
	// #o#
	// ##x
	private func doubleThreeFour(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x + 3, point.y + 3), spot) &&
			checkSpotCoordinate(Point(point.x + 2, point.y + 2), spot) &&
			checkSpotCoordinate(Point(point.x + 1, point.y + 1), .empty)
		two =
			checkSpotCoordinate(Point(point.x + 2, point.y + 2), spot) &&
			checkSpotCoordinate(Point(point.x + 1, point.y + 1), spot)
		return one || two
	}
	
	// ###
	// #o#
	// #x#
	private func doubleThreeFive(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x + 3, point.y), spot) &&
			checkSpotCoordinate(Point(point.x + 2, point.y), spot) &&
			checkSpotCoordinate(Point(point.x + 1, point.y), .empty)
		two =
			checkSpotCoordinate(Point(point.x + 2, point.y), spot) &&
			checkSpotCoordinate(Point(point.x + 1, point.y), spot)
		return one || two
	}
	
	// ###
	// #o#
	// x##
	private func doubleThreeSix(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x + 3, point.y - 3), spot) &&
			checkSpotCoordinate(Point(point.x + 2, point.y - 2), spot) &&
			checkSpotCoordinate(Point(point.x + 1, point.y - 1), .empty)
		two =
			checkSpotCoordinate(Point(point.x + 2, point.y - 2), spot) &&
			checkSpotCoordinate(Point(point.x + 1, point.y - 1), spot)
		return one || two
	}
	
	// ###
	// xo#
	// ###
	private func doubleThreeSeven(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x, point.y - 3), spot) &&
			checkSpotCoordinate(Point(point.x, point.y - 2), spot) &&
			checkSpotCoordinate(Point(point.x, point.y - 1), .empty)
		two =
			checkSpotCoordinate(Point(point.x, point.y - 2), spot) &&
			checkSpotCoordinate(Point(point.x, point.y - 1), spot)
		return one || two
	}
	
	// x##
	// #o#
	// ###
	private func doubleThreeEight(point: Point, spot: Spot) -> Bool {
		var one = false
		var two = false
		one =
			checkSpotCoordinate(Point(point.x - 3, point.y - 3), spot) &&
			checkSpotCoordinate(Point(point.x - 2, point.y - 2), spot) &&
			checkSpotCoordinate(Point(point.x - 1, point.y - 1), .empty)
		two =
			checkSpotCoordinate(Point(point.x - 2, point.y - 2), spot) &&
			checkSpotCoordinate(Point(point.x - 1, point.y - 1), spot)
		return one || two
	}
}

extension String : Error { }

