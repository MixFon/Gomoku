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
	
	func opposite() -> Stone {
		switch self {
		case .black:
			return .white
		case .white:
			return .black
		}
	}
}

class Board {
	
	var board = Array(repeating: Array(repeating: Spot.empty, count: 19), count: 19)
	
	/// 4 ставится потому что учитывается камень который ставится
	private let numberStonesToWin = 4
	
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
	
	/// Перечисление служит для назначения значения при расчете стоимости spot при расчете тройки
	enum SpotWeight: Int {
		case empty = 0
		case current = 2
		case opposite = 3
		case offBouard = 5
	}
	
	/// Направление движения, используется при подряд идущих камней.
	enum Direction {
		case up
		case down
	}
	
	/// Возвращает кортеж ко
	func getWhiteBlackPointsSpot() -> ([Point],[Point]) {
		var whitePoint = [Point]()
		var blackPoint = [Point]()
		for (i, line) in self.board.enumerated() {
			for (j, spot) in line.enumerated() {
				switch spot {
				case .white:
					whitePoint.append(convertCoordinateToGlobal(point: Point(i, j)))
				case .black:
					blackPoint.append(convertCoordinateToGlobal(point: Point(i, j)))
				case .empty:
					continue
				}
			}
		}
		return (whitePoint, blackPoint)
	}
	
	/// Вызывается при закрузке сохраненной игры. На доске устанавливаются нужные spots
	func setStartSpotsOnBouard(whitePoints: [Point], blackPoints: [Point]) {
		for point in whitePoints {
			let pointInBoard = convertCoordinateToBoard(point: point)
			setSpot(point: pointInBoard, spot: .white)
		}
		for point in blackPoints {
			let pointInBoard = convertCoordinateToBoard(point: point)
			setSpot(point: pointInBoard, spot: .black)
		}
	}
	
	/// Установка всех значений доски в empty (удаление всех элементов с доски)
	func clearBoard() {
		for i in self.board.indices {
			for j in self.board[i].indices {
				self.board[i][j] = .empty
			}
		}
	}
	
	/// Установка спота  нужного цвета в указанную координату. Предварительно делает провкрку на размещение
	func placeStone(point: Point, stone: Stone) -> Bool {
		let point = convertCoordinateToBoard(point: point)
		if !checkSpotCoordinate(point, .empty) {
			return false
		}
		guard let spot = Spot(rawValue: stone.rawValue) else { return false }
		if !checkDoubleThree(point: point, spot: spot) {
			return false
		}
//		Убрать проверку на переход в захват, переходить в захват можно 
//		if !checkCaptures(point: point, spot: spot) {
//			return false
//		}
		setSpot(point: point, spot: spot)
		return true
	}
	
	/// Первод коорлинаты в систему координат доски (модели)
	private func convertCoordinateToBoard(point: Point) -> Point {
		return Point(point.x + 9, point.y + 9)
	}
	
	/// Перевод координаты в глобальную систему поординат.
	private func convertCoordinateToGlobal(point: Point) -> Point {
		return Point(point.x - 9, point.y - 9)
	}
	
	/// Проверка захвата. Если захват возможен возвращает коршеж точек камней которые нужно удалить с доски.
	func captures(point: Point, stone: Stone) -> (Point, Point)? {
		let point = convertCoordinateToBoard(point: point)
		guard let spot = Spot(rawValue: stone.rawValue) else { return nil }
		guard let points = isCaptures(point: point, spot: spot) else { return nil }
		print(points)
		deleteSpot(points: points)
		let firstPoint = convertCoordinateToGlobal(point: points.0)
		let secondPoint = convertCoordinateToGlobal(point: points.1)
		return (firstPoint, secondPoint)
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
		//print("nil")
		return nil
	}
	
	/// Установка спота нужного цвета на доску в заданную координату
	private func setSpot(point: Point, spot: Spot) {
		self.board[point.x][point.y] = spot
	}
	
	/// Проверяет нахождение коорлинаты на доске. true если координата не входит на доску
	private func inBoard(point: Point) -> Bool {
		return (point.x < 0 || point.x >= 19 || point.y < 0 || point.y >= 19)
	}
	
	/// Проверяет нахотится ли в указанной точке указанный спот. true - находится false - нет. Проверка на вхождение на доску НЕ проводится
	private func isSpotInBouard(_ point: Point,_ spot: Spot) -> Bool {
		return self.board[point.x][point.y] == spot
	}
	
	/// Проверка на то что в координате находится установленный спот true - находится false - нет
	private func checkSpotCoordinate(_ point: Point, _ spot: Spot) -> Bool {
		if inBoard(point: point) {
			return false
		}
		return isSpotInBouard(point, spot)
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
	
	// MARK: Проветка двойной троки (новый вариант)
	/// Проверяет наличие троек. Если тройка есть, возвращает массив точек составляющее тройку.
	func checkDoubleThree(point: Point, spot: Spot) -> Bool {
		if let points = checkThree(point: point, spot: spot) {
			for point in points {
				print(point)
			}
		}
		return true
	}
	
	/// Возвращает вес spot. Текущий - 2, противоположный - 3, пустой - 0, конец доски - 5
	private func getWeightOfSpor(point: Point, spot: Spot) -> SpotWeight {
		// Если конец доски
		if inBoard(point: point) {
			return .offBouard
		}
		// Если текущий spot
		if isSpotInBouard(point, spot) {
			return .current
		}
		// Если противоположный spot
		if isSpotInBouard(point, spot.opposite()) {
			return .opposite
		}
		// Остается только пустой spot, он равен 0
		return .empty
	}
	
	// #x#
	// #o#
	// #x#
	private func checkOne(point: Point, i: Int, direction: Direction) -> Point {
		switch direction {
		case .up:
			return Point(point.x - i, point.y)
		case .down:
			return Point(point.x + i, point.y)
		}
	}
	
	// ##x
	// #o#
	// x##
	private func checkTwo(point: Point, i: Int, direction: Direction) -> Point {
		switch direction {
		case .up:
			return Point(point.x - i, point.y + i)
		case .down:
			return Point(point.x + i, point.y - i)
		}
	}
	
	// ###
	// xox
	// ###
	private func checkThree(point: Point, i: Int, direction: Direction) -> Point {
		switch direction {
		case .up:
			return Point(point.x, point.y + i)
		case .down:
			return Point(point.x, point.y - i)
		}
	}
	
	// x##
	// #o#
	// ##x
	private func checkFour(point: Point, i: Int, direction: Direction) -> Point {
		switch direction {
		case .up:
			return Point(point.x + i, point.y + i)
		case .down:
			return Point(point.x - i, point.y - i)
		}
	}
	
	/// Проверка идущих подрят троеек
	private func checkThree(point: Point, spot: Spot) -> [Point]? {
		return checkThreeAll(point: point, spot: spot,nextPoint: checkOne)
	}

	/// Проверка двойных троек по всех 8 направлениям
	private func checkThreeAll(point: Point, spot: Spot,nextPoint: ((Point, Int, Direction) -> Point)) -> [Point]?{
		var points = [point]
		var index = 4;
		var summa = 0
		for i in 1...index {
			let up = nextPoint(point, i, .up)
			let weight = getWeightOfSpor(point: up, spot: spot)
			index -= 1
			summa += weight.rawValue
			if weight == .current {
				points.append(up)
			} else {
				break
			}
		}
		if index == 0 {
			return nil
		}
		for i in 1...index {
			let down = nextPoint(point, i, .down)
			let weight = getWeightOfSpor(point: down, spot: spot)
			summa += weight.rawValue
			if weight == .current {
				points.append(down)
			} else {
				break
			}
		}
		if summa == 4 {
			return points
		} else {
			return nil
		}
	}
	
	/// Проверка пяти стоящих подряд камней.
	func checkWinerToFiveSpots(point: Point, stone: Stone) -> Bool {
		// -1 ставится потому что учитывается камень, который ставится
		return checkingConsecutiveStones(point: point, stone: stone)
	}
	
	// MARK: Проверка пяти подряд идущих камней.
	/// Проверяет подряд идущие камни, во всех 8 направлениях на доске.
	private func checkingConsecutiveStones(point: Point, stone: Stone) -> Bool {
		let point = convertCoordinateToBoard(point: point)
		guard let spot = Spot(rawValue: stone.rawValue) else { return false }
		if checkFiveAll(point: point, spot: spot, nextPoint: checkOne) {
			return true
		}
		if checkFiveAll(point: point, spot: spot, nextPoint: checkTwo) {
			return true
		}
		if checkFiveAll(point: point, spot: spot, nextPoint: checkThree) {
			return true
		}
		if checkFiveAll(point: point, spot: spot, nextPoint: checkFour) {
			return true
		}
		return false
	}
	
	/// Проверка пяти идущих подряд камней, определяется для определения победителя
	private func checkFiveAll(point: Point, spot: Spot, nextPoint: ((Point, Int, Direction) -> Point)) -> Bool {
		var count = 0
		for i in 1...self.numberStonesToWin {
			let up = nextPoint(point, i, .up)
			if !checkSpotCoordinate(up, spot) {
				break
			}
			count += 1
		}
		for i in 1...self.numberStonesToWin {
			let down = nextPoint(point, i, .down)
			if !checkSpotCoordinate(down, spot) {
				break
			}
			count += 1
		}
		return count >= self.numberStonesToWin
	}
}

extension String : Error { }

/*
// MARK: Проверка двойной тройки (неверно работает)
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
*/

