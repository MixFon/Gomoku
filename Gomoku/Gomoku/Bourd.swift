//
//  Bourd.swift
//  Gamoku
//
//  Created by Михаил Фокин on 15.10.2021.
//

import Foundation

class Board {
	
	/// Используется для обработка случая расстановки Rabbit
	typealias RabbitFunction = (Point, Spot, ((Point, Int, Direction) -> Point)) -> [Point]?
	typealias NextPoint = ((Point, Int, Direction) -> Point)
	
	typealias Weight = UInt16
	
	weak var delegate: MoveProtocol?
	
	private var board = Array(repeating: Array(repeating: Weight(0), count: 19), count: 19)
	
	/// Количество камней для попеды. 4 ставится потому что учитывается камень который ставится
	private let numberStonesToWin = 4
	
	/// Максимальный вес для белых spot
	private var bestPointWhite = BestPoint(point: Point(-1, -1), weight: 0)
	/// Максимальный вес для черных spot
	private var bestPointBlack = BestPoint(point: Point(-1, -1), weight: 0)
	
	/// Точки в которых была найдена двойная тройка. Эти точки нужно пересчитывать.
	private var pointsDoubleThree = Set<Point>()
	
	/// Точки в которых обнаружен захват. Если в нее перейти будет захват.
	private var pointsCapturesWhite = Set<Point>()
    
    /// Точки в которых обнаружен захват. Если в нее перейти будет захват.
    private var pointsCapturesBlack = Set<Point>()
	
	/// Текущий spot, для определения, кото должен ходить в данный момент. Первые ходят белые.
	private var currentSpot = Spot.white
	
	/// Количество захватов, произведенные белыми
	private var whiteCaptures: Int = 0
	/// Количество захватов, произведенные черными
	private var blackCaptures: Int = 0
	
	init() { }
	
	init(board :Board) {
		self.board = board.board
		self.bestPointWhite = board.bestPointWhite
		self.bestPointBlack = board.bestPointBlack
		self.currentSpot = board.currentSpot
		self.whiteCaptures = board.whiteCaptures
		self.blackCaptures = board.blackCaptures
		self.pointsDoubleThree = board.pointsDoubleThree
		self.pointsCapturesWhite = board.pointsCapturesWhite
        self.pointsCapturesBlack = board.pointsCapturesBlack
		self.delegate = nil
	}
	
	init(save :Save) {
		self.board = save.board!
		self.bestPointWhite = save.bestPointWhite!
		self.bestPointBlack = save.bestPointBlack!
		self.currentSpot = Spot(rawValue: Character(save.stone!))!
		self.whiteCaptures = save.whiteCaptures!
		self.blackCaptures = save.blackCaptures!
		self.pointsDoubleThree = save.pointsDoubleThree!
        self.pointsCapturesWhite = save.pointsCapturesWhite!
		self.pointsCapturesBlack = save.pointsCapturesBlack!
		self.delegate = nil
	}
	
	// MARK: Structs
	struct BestPoint: Codable {
		var point: Point
		var weight: Weight
	}
	
	// MARK: Enums
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
	
	enum Spot: Character {
		case white = "W"
		case black = "B"
		case empty = "."
		
		init(weight: Weight) {
			switch weight {
			case 0x100:
				self = .white
			case 0x1:
				self = .black
			default:
				self = .empty
			}
		}
		
		init?(optional weight: Weight) {
			switch weight {
			case 0x100:
				self = .white
			case 0x1:
				self = .black
			default:
				return nil
			}
		}
		
		/// Возврат противоположенного значения
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
		
		/** Возвращет числовое значение веса  spot.
			0x100 - белые (левая васть числа)
			0x1 - берные (правая часть числа)
			0x0 - пустая ячейка.*/
		func wieghtSpot() -> Weight {
			switch self {
			case .white:
				return 0x100
			case .black:
				return 0x1
			case .empty:
				return 0x0
			}
		}
	}
	// MARK: Get Set
	/// Возвращает количество захватов, произведенные белыми
	func getWhiteCaptures() -> Int {
		return self.whiteCaptures
	}
	
	/// Возвращает количество захватов, произведенные черными
	func getBlackCaptures() -> Int {
		return self.blackCaptures
	}
	
	/// Устанавливае количество захватов, произведенные белыми
	func setWhiteCaptures(captures: Int) {
		self.whiteCaptures = captures
	}
	
	/// Устанавливае количество захватов, произведенные черными
	func setBlackCaptures(captures: Int) {
		self.blackCaptures = captures
	}
	
	/// Возвращает текущий Spot
	func getCurrentSpot() -> Spot {
		return self.currentSpot
	}
	
	/// Устанавливает  текущий Spot
	func setCurrentSpot(spot: Spot) {
		self.currentSpot = spot
	}
	
	/// Возвращает текущий Spot в виде строки
	func getCurrentSpotString() -> String {
		return String(self.currentSpot.rawValue)
	}
	
	/// Возвращает максимальный вес для белых spot
	func getBestPointWhite() -> BestPoint {
		return self.bestPointWhite
	}
	
	/// Возвращает максимальный вес для четных spot
	func getBestPointBlack() -> BestPoint {
		return self.bestPointBlack
	}
	
	/// Устанавливает максимальный вес для белых spot
	func setBestPointWhite(bestPoint: BestPoint) {
		self.bestPointWhite = bestPoint
	}
	
	/// Устанавливает максимальный вес для четных spot
	func setBestPointBlack(bestPoint: BestPoint) {
		self.bestPointBlack = bestPoint
	}
	
    /// Возвращает массив белых точек, в которых обнаружен захват
    func getPointsCapturesWhiteArray() -> [Point] {
        return self.pointsCapturesWhite.map({$0})
    }
    
	/// Возвращает массив черных точек, в которых обнаружен захват
	func getPointsCapturesBlackArray() -> [Point] {
		return self.pointsCapturesBlack.map({$0})
	}
    
    /// Возвращает набор белых точек, в которых обнаружен захват
    func getPointsCapturesWhite() -> Set<Point> {
        return self.pointsCapturesWhite
    }
	
	/// Возвращает набор черных точек, в которых обнаружен захват
	func getPointsCapturesBlack() -> Set<Point> {
		return self.pointsCapturesBlack
	}
	
    /// Устанавливает набор белых точек, в которых обнаружен захват
    func setPointsCapturesWhite(points: Set<Point>) {
        self.pointsCapturesWhite = points
    }
    
	/// Устанавливает набор черных точек, в которых обнаружен захват
	func setPointsCapturesBlack(points: Set<Point>) {
		self.pointsCapturesBlack = points
	}
	
	/// Возвращает точки, в которых была найдена двойная тройка.
	func getPointsDoubleThree() -> Set<Point> {
		return self.pointsDoubleThree
	}
	
	/// Устанавливает точки, в которых была найдена двойная тройка.
	func setPointsDoubleThree(points: Set<Point>){
		self.pointsDoubleThree = points
	}
	
	/// Установка делегата. Им должент быть кдасс GameViewController
	func setDelegate(delegate: MoveProtocol) {
		self.delegate = delegate
	}
	
	/// Возвращает доску, ка которых расположены веса.
	func getBoard() -> [[Weight]] {
		return self.board
	}
	// MARK: Get Set for best points
	/// Возвращает массив точек в которые предпочтительнее всего ставить. Возвращабтся точки для currentSpot
	func getBestPoints() -> [Point] {
        var points = [self.bestPointWhite.point, self.bestPointBlack.point]
        if self.currentSpot == .white {
            points.append(contentsOf: getPointsCapturesWhiteArray())
        } else {
            points.append(contentsOf: getPointsCapturesBlackArray())
        }
		return points
	}
	
	/// Возвращает максимальный наилучший вес для текущего spot.
	func getBestWeigthForCurrentSpot() -> Weight {
		return getWeight(point: getBestPoint())
	}
	
	/// Возвращает вес в указанной точке. Полностю для всей точки.
	func getWeight(point: Point) -> Weight {
		return self.board[point.x][point.y]
	}
	
	/// Устанавливает текущий spot в заданную позицию. Ипользуется в miniMax перед переходом на следующий уровень.
	func setCurrentSpotToPoint(point: Point) {
		setSpot(point: point, spot: self.currentSpot)
	}
	
	/// Устанавливает вес как он есть в заданную позицию, затем одновляет позицию
	func setConstWeightToPoint(point: Point, weight: Weight) {
		self.board[point.x][point.y] = weight
		updateBestPoints(point: point, weight: self.board[point.x][point.y])
	}
	
	// MARK: Functions
	/// Возвращает массив черных и белых камней с их координатами (глобальными)
	func getPointStones() -> [Gomoku.PointStone] {
		var pointStones = [Gomoku.PointStone]()
		for i in 0..<19 {
			for j in 0..<19 {
				if let spot = Spot(optional: self.board[j][i]) {
					if let stone = Stone(spot: spot) {
						let point = convertCoordinateToGlobal(point: Point(j, i))
						pointStones.append(Gomoku.PointStone(point: point, stone: stone))
					}
				}
			}
		}
		return pointStones
	}
	
	/// Если максимальный вес противника меньше 9 (8, 7, 6...) возвращем точку своего (текущего) веса.
	private func returnBelowNine(bestWhite: Weight, bestBlack: Weight) -> Point? {
		switch self.currentSpot {
		case .black where bestWhite <= 8:
			return self.bestPointBlack.point
		case .white where bestBlack <= 8:
			return self.bestPointWhite.point
		default:
			break
		}
		return nil
	}
	
	/// Возвращает точку в которую лучше всего поставить текущий камень
	func getBestPoint() -> Point {
		let (bestWhite, b) = Board.getWeightWhiteBlack(weight: self.bestPointWhite.weight)
		let (w, bestBlack) = Board.getWeightWhiteBlack(weight: self.bestPointBlack.weight)
		if let pointBelowNine = returnBelowNine(bestWhite: bestWhite, bestBlack: bestBlack) {
			return pointBelowNine
		}
		if bestWhite == bestBlack {
			let deltaWhite = abs(Int(bestWhite) - Int(b))
			let deltaBlack = abs(Int(w) - Int(bestBlack))
			if deltaWhite == deltaBlack {
				if self.currentSpot == .black {
					if bestWhite >= 10 {
						return self.bestPointWhite.point
					} else {
						return self.bestPointBlack.point
					}
				} else {
					if bestBlack >= 10 {
						return self.bestPointBlack.point
					} else {
						return self.bestPointWhite.point
					}
				}
			}
			if deltaWhite < deltaBlack {
				return self.bestPointWhite.point
			} else {
				return self.bestPointBlack.point
			}
		} else {
			if bestWhite > bestBlack {
				return self.bestPointWhite.point
			} else {
				return self.bestPointBlack.point
			}
		}
	}
	
	/// (Не используется) Устанавливает вес в заданную позицию. В позиции сохраняется наибольший вес
	func setWeightToPoint(point: Point, weight: Weight) {
		let (oldWhite, oldBlack) = Board.getWeightWhiteBlack(weight: self.board[point.x][point.y])
		let maxOld = max(oldWhite, oldBlack)
		let (settingWhite, settingBlack) = Board.getWeightWhiteBlack(weight: weight)
		let maxSetting = max(settingWhite, settingBlack)
		// Если максимальные значения устанавливаемого и установленного весов равны
		if maxSetting == maxOld {
			// Высичляем разности и устанавливаем наименьшую разность
			let deltaOld = abs(Int(oldWhite) - Int(oldBlack))
			let deltaSetting = abs(Int(settingWhite) - Int(settingBlack))
			// Если разности равны, устаравливаем разность для текущего камня.
			if deltaOld == deltaSetting {
				if self.currentSpot == .white {
					if settingWhite > settingBlack {
						self.board[point.x][point.y] = weight
					}
				} else {
					if settingWhite < settingBlack {
						self.board[point.x][point.y] = weight
					}
				}
			} else {
				if deltaSetting < deltaOld {
					self.board[point.x][point.y] = weight
				}
			}
		} else {
			if maxSetting > maxOld {
				self.board[point.x][point.y] = weight
			}
		}

	}
	
	/// Обновление весов в нучших координатах
	func updateBestPoints(point: Point, weight: Weight) {
		// Проверяет на то, что в ячейке нет W или B. Любой другой вес считается .empty
		if !checkSpotCoordinate(self.bestPointWhite.point, .empty) {
			self.bestPointWhite.point = Point(-1, -1)
			self.bestPointWhite.weight = 1
		}
		if !checkSpotCoordinate(bestPointBlack.point, .empty) {
			bestPointBlack.point = Point(-1, -1)
			bestPointBlack.weight = 1
		}
		// Проверяет на то, что мы затираем точку, максимального значения.
		if (self.bestPointWhite.point == point) {
			self.bestPointWhite.point = Point(-1, -1)
			self.bestPointWhite.weight = 1
		}
		if (self.bestPointBlack.point == point) {
			self.bestPointBlack.point = Point(-1, -1)
			self.bestPointBlack.weight = 1
		}
		
		let (white, black) = Board.getWeightWhiteBlack(weight: weight)
		let (bestWhite, b) = Board.getWeightWhiteBlack(weight: self.bestPointWhite.weight)
		let (w, bestBlack) = Board.getWeightWhiteBlack(weight: self.bestPointBlack.weight)
		
		// White
		if bestWhite == white {
			let deltaOld = abs(Int(bestWhite) - Int(b))
			let deltaSetting = abs(Int(white) - Int(black))
			if deltaSetting < deltaOld {
				self.bestPointWhite.point = point
				self.bestPointWhite.weight = weight
			}
		} else if bestWhite < white {
			self.bestPointWhite.point = point
			self.bestPointWhite.weight = weight
		}
		
		// Black
		if bestBlack == black {
			let deltaOld = abs(Int(w) - Int(bestBlack))
			let deltaSetting = abs(Int(white) - Int(black))
			if deltaSetting < deltaOld {
				self.bestPointBlack.point = point
				self.bestPointBlack.weight = weight
			}
		} else if bestBlack < black {
			self.bestPointBlack.point = point
			self.bestPointBlack.weight = weight
		}
	}
	
	/// Сложение весов. Правые скзадывает с правыми левые с левыми
	private func addingWeights(one: Weight, two: Weight) -> Weight {
		// 16 oct, 8 left oct - white, 8 right oct - black
		var result = one
		let (whiteOne, blackOne) = Board.getWeightWhiteBlack(weight: one)
		let (whiteTwo, blackTwo) = Board.getWeightWhiteBlack(weight: two)
		result = whiteOne + whiteTwo
		result = result << 8
		result = result | (blackOne + blackTwo)
		return result
	}
	
	/// Возвращает кортеж координат
	func getWhiteBlackPointsSpot() -> ([Point], [Point]) {
		var whitePoint = [Point]()
		var blackPoint = [Point]()
		for (i, line) in self.board.enumerated() {
			for (j, weight) in line.enumerated() {
				let spot = Spot(weight: weight)
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
	
	/// Установка всех значений доски в empty (удаление всех элементов с доски)
	func clearBoard() {
		self.whiteCaptures = 0
		self.blackCaptures = 0
		for i in self.board.indices {
			for j in self.board[i].indices {
				self.board[i][j] = Spot.empty.wieghtSpot()
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
		setSpot(point: point, spot: spot)
		return true
	}
	
	/// Первод коорлинаты в систему координат доски (модели)
	func convertCoordinateToBoard(point: Point) -> Point {
		return Point(point.x + 9, point.y + 9)
	}
	
	/// Перевод координаты в глобальную систему поординат.
	func convertCoordinateToGlobal(point: Point) -> Point {
		return Point(point.x - 9, point.y - 9)
	}
	
	/// Проверка захвата. Если захват возможен удаляет камки с доски и вызывает делегат по удалению камней.
	func captures(point: Point, spot: Spot) {
		guard let points = isCaptures(point: point, spot: spot) else { return }
		if spot == .white {
			self.whiteCaptures += 1
		} else {
			self.blackCaptures += 1
		}
		deleteSpotCurrentBoard(points: points)
		deleteSpotFromDelegate(points: points, spot: spot)
	}
	
	/// Удаление. Установка в точки значение .empty. Перерасчет весов в областях удаленных spot.
	private func deleteSpotCurrentBoard(points: (Point, Point)) {
		self.board[points.0.x][points.0.y] = Spot.empty.wieghtSpot()
		self.board[points.1.x][points.1.y] = Spot.empty.wieghtSpot()
		definingPointsForRecalculation(point: points.0)
		definingPointsForRecalculation(point: points.1)
	}
	
	/// Удаляет споты в указанных координатах, используется при захвате камней. И удалаяе с 3D доски.
	private func deleteSpotFromDelegate(points: (Point, Point), spot: Spot) {
		if let delegate = self.delegate {
			let firstPoint = convertCoordinateToGlobal(point: points.0)
			let secondPoint = convertCoordinateToGlobal(point: points.1)
			guard let stone = Stone(rawValue: spot.opposite().rawValue) else { return }
			delegate.delete(points: (firstPoint, secondPoint), stone: stone)
		}
	}
	
	/// Проверяет возможен ли захват вражеских камней
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
		return nil
	}
	
	// MARK: Определение точек для перерасчета и перерасчет весов.
	/// Определение точек для пресчета. Во всех 8 направлениях. Вычисление в каждой точке веса
	private func definingPointsForRecalculation(point: Point) {
		// #x#
		// #o#
		// #x#
		definingPoints(point: point, nextPoint: checkOne, direction: .up)
		definingPoints(point: point, nextPoint: checkOne, direction: .down)
		
		// ##x
		// #o#
		// x##
		definingPoints(point: point, nextPoint: checkTwo, direction: .up)
		definingPoints(point: point, nextPoint: checkTwo, direction: .down)
		
		// ###
		// xox
		// ###
		definingPoints(point: point, nextPoint: checkThree, direction: .up)
		definingPoints(point: point, nextPoint: checkThree, direction: .down)
		
		// x##
		// #o#
		// ##x
		definingPoints(point: point, nextPoint: checkFour, direction: .up)
		definingPoints(point: point, nextPoint: checkFour, direction: .down)
	}
	
	//    .     .
	//	  .     .
	//	  W	    B	  .
	//	  W	    B	  .
	// 1. x  2. x  3. x  при x == W. x - текущая позиция, W - текущий камени, B - противоположный, . - проврка
	/// Определение точек для перерасчета.
	private func definingPoints(point: Point, nextPoint: NextPoint, direction: Direction) {
		let currentSpot = self.currentSpot
		var i = 1
		var checkPoint = nextPoint(point, i, direction)
		if checkSpotCoordinate(checkPoint, currentSpot) {
			// 1.
			repeat {
				i += 1
				checkPoint = nextPoint(point, i, direction)
			} while checkSpotCoordinate(checkPoint, currentSpot)
			recalculateWeight(point: checkPoint)
		} else if checkSpotCoordinate(checkPoint, currentSpot.opposite()) {
			// 2.
			repeat {
				i += 1
				checkPoint = nextPoint(point, i, direction)
			} while checkSpotCoordinate(checkPoint, currentSpot.opposite())
			recalculateWeight(point: checkPoint)
		} else {
			// 3.
			recalculateWeight(point: checkPoint)
		}
		
		// Рассмотривают только точки по контуру.
		i += 1
		checkPoint = nextPoint(point, i, direction)
		recalculateWeight(point: checkPoint)
	}
	
	/// Пересчет весов
	private func recalculateWeight(point: Point) {
		if !checkSpotCoordinate(point, .empty) { return }
		let weightWhite = calculateWeightToWhiteBlack(point: point, spot: .white)
		let weightBlack = calculateWeightToWhiteBlack(point: point, spot: .black)
		let result: Weight = (weightWhite << 8) | (weightBlack & 0xff)
		setConstWeightToPoint(point: point, weight: result)
	}
	
	/// Пересчет весов оносительно белого spot
	private func calculateWeightToWhiteBlack(point: Point, spot: Spot) -> Weight {
		var maxPriority: Weight = 0
		var priority: Weight = 0
		var flagCaptures = false
		maxPriority = calculateWeight(point: point, spot: spot, nextPoint: checkOne)
		if (maxPriority == 2) { flagCaptures = true }
		priority = calculateWeight(point: point, spot: spot, nextPoint: checkTwo)
		if (priority == 2) { flagCaptures = true }
		maxPriority = max(maxPriority, priority)
		priority = calculateWeight(point: point, spot: spot, nextPoint: checkThree)
		if (priority == 2) { flagCaptures = true }
		maxPriority = max(maxPriority, priority)
		priority = calculateWeight(point: point, spot: spot, nextPoint: checkFour)
		if (priority == 2) { flagCaptures = true }
		maxPriority = max(maxPriority, priority)
		if isCaptures(point: point, spot: spot) != nil {
			if spot == .white {
				maxPriority += UInt16((self.whiteCaptures + 2) % 10)
                self.pointsCapturesWhite.insert(point)
			} else {
				self.pointsCapturesBlack.insert(point)
				maxPriority += UInt16((self.blackCaptures + 2) % 10)
			}
		}
		if flagCaptures {
			if maxPriority < 9 {
				return 2
			}
		}
		return maxPriority
	}
	
	/// Общая функция для расчета весов
	private func calculateWeight(point: Point, spot: Spot, nextPoint: NextPoint) -> Weight {
		let maxIteration = 6
		if !checkDoubleThree(point: point, spot: spot) {
			// Добавление точки для дальнейшего пересчета.
			self.pointsDoubleThree.insert(point)
			return 0
		}
		var sameStones = 0
		var oppositeStones = 0
		var i = 1
		var checkPoint = nextPoint(point, i, .up)
		if !checkSpotCoordinate(checkPoint, .empty) {
			for k in i..<maxIteration {
				checkPoint = nextPoint(point, k, .up)
				if checkSpotCoordinate(checkPoint, spot) {
					sameStones += 1
				} else if checkSpotCoordinate(checkPoint, spot.opposite()) {
					oppositeStones += 1
					break
				} else {
					break
				}
			}
		}
		
		// down
		i = 1
		sameStones += 1 // Увеличиваем на 1, тем самым учитываем рассматриваемую точку.
		checkPoint = nextPoint(point, i, .down)
		if !checkSpotCoordinate(checkPoint, .empty) {
			for k in i..<maxIteration {
				checkPoint = nextPoint(point, k, .down)
				if checkSpotCoordinate(checkPoint, spot) {
					sameStones += 1
				} else if checkSpotCoordinate(checkPoint, spot.opposite()) {
					oppositeStones += 1
					break
				} else {
					break
				}
			}
		}
		return getPrioritet(same: sameStones, opposite: oppositeStones)
	}
	
	/// Печать доски
	func printBourd() {
		print("  ", terminator: "")
		for i in 0...18 {
			if i < 10 {
				print(" \(i)  ", terminator: "")
			} else {
				print(" \(i) ", terminator: "")
			}
		}
		print()
		for i in 0..<19 {
			if i < 10 {
				print("\(i) |", terminator: "")
			} else {
				print("\(i)|", terminator: "")
			}
			for j in 0..<19 {
				if self.board[j][i] == 0x100 || self.board[j][i] == 0x1 || self.board[j][i] == 0x0 {
					let spot = Spot(weight: self.board[j][i])
					print(" \(spot.rawValue)  ", terminator: "")
				} else {
					print("\(self.board[j][i] >> 8 & 0xff)|\(self.board[j][i] & 0xff)", terminator: " ")
				}
			}
			print()
		}
	}
	
	// MARK: Установка весов

	/// Высичление приоритета на основе данных
	private func getPrioritet(same: Int, opposite: Int) -> Weight {
		// минимальное значение для same равно 1 потому что учитывается камень, который ставится
		switch opposite {
		case 0: // 0 противоположных камней
			switch same {
			case 1:
				return 4
			case 2:
				return 5
			case 3:
				return 7
			case 4:
				return 9
			case 5:
				return 10
			default:
				return 11
			}
		case 1: // 1 камень противоположной стороны
			switch same {
			case 1:
				return 3
			case 2:
				return 2
			case 3:
				return 6
			case 4:
				return 8
			case 5:
				return 10
			default:
				return 11
			}
		case 2:
			if same >= 5 {
				return 10
			} else {
				return 3
			}
		default:
			break
		}
		return 0
	}
	
	/// Установка спота нужного цвета на доску в заданную координату. Так же происходит перемена spot на противоположенный.
	/// Предполагается, что в заданную позицию можно установить заданный spot
	func setSpot(point: Point, spot: Spot) {
		captures(point: point, spot: spot)
		self.board[point.x][point.y] = spot.wieghtSpot()
		recalcularePointsDoubleThree()
		definingPointsForRecalculation(point: point)
		updatePointsCaptures(point: point)
		self.currentSpot = self.currentSpot.opposite()
	}
	
	/// Обновляет точки для белых и черных в которых может быть захват.
    /// Исключает ту точку, которая была поставлена только что
	private func updatePointsCaptures(point: Point) {
		if !self.pointsCapturesBlack.isEmpty {
            self.pointsCapturesBlack.subtract([point])
        }
        if !self.pointsCapturesWhite.isEmpty {
            self.pointsCapturesWhite.subtract([point])
        }
	}
	
	/// Пересчет точек в которые раньше нельзя было поставить указанный spot
	private func recalcularePointsDoubleThree() {
		if self.pointsDoubleThree.isEmpty { return }
		let tempPointsDoubleThree = self.pointsDoubleThree.map( {$0} )
		self.pointsDoubleThree.removeAll()
		tempPointsDoubleThree.forEach( { recalculateWeight(point: $0) } )
	}
	
	// MARK: Проверки координат и установок
	
	/// Проверяет нахождение коорлинаты на доске. true если координата не входит на доску
	private func inBoard(point: Point) -> Bool {
		return (point.x < 0 || point.x >= 19 || point.y < 0 || point.y >= 19)
	}
	
	/// Проверяет нахотится ли в указанной точке указанный спот. true - находится false - нет. Проверка на вхождение на доску НЕ проводится
	private func isSpotInBouard(_ point: Point, _ spot: Spot) -> Bool {
		let checkSpot = Spot(weight: self.board[point.x][point.y])
		return checkSpot.wieghtSpot() == spot.wieghtSpot()
	}
	
	/// Проверка на то что в координате находится установленный spot true - находится false - нет
	private func checkSpotCoordinate(_ point: Point, _ spot: Spot) -> Bool {
		if inBoard(point: point) {
			return false
		}
		return isSpotInBouard(point, spot)
	}
	
	// MARK: Проветка двойной троки (новый вариант)
	// Нужно будет упростить вариант в случае долгой работы.
	/// Проверяет наличие троек. Если тройка есть подсвечивает ее. True - двойной тройки нет, false - двойная тройка есть
	func checkDoubleThree(point: Point, spot: Spot) -> Bool {
		var setResult = Set<Point>()
        let uniqueStone = uniquePointThree(point: point, spot: spot)
		for point in uniqueStone {
			let unique = uniquePointThree(point: point, spot: spot)
			setResult = setResult.union(unique)
		}
		return setResult.count == 3 || setResult.count == 0
        /*
		// Вариан с подсвечиваение тройки
		//print(setResult)
		if setResult.count == 3 || setResult.count == 0 {
			for uniquePoint in setResult {
				let point = convertCoordinateToGlobal(point: uniquePoint)
				self.delegate?.stoneShine(point: point, color: .green)
			}
			return true
		} else {
			for uniquePoint in setResult {
				let point = convertCoordinateToGlobal(point: uniquePoint)
				self.delegate?.stoneShine(point: point, color: .red)
			}
			return false
		}
		*/
	}
	
	/**
	Возвращает уникальные элементы состовляющие тройки по всем направлениям.
	*/
	private func uniquePointThree(point: Point, spot: Spot) -> Set<Point> {
		var setPoints = Set<Point>()
		checkThree(point: point, spot: spot, setPoints: &setPoints)
		checkThreeRabbit(point: point, spot: spot, setPoints: &setPoints)
		return setPoints
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
	
	// MARK: Функции для перемещения по 8 направлениям
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
	
	// MARK: Проверка тройки в виде кролика
	
	// up x o x down
	// где x - empty spot, o текущая точка, . spot  такого же типа как и o
	/// Проверяет xox во всех 8 направлениях. Если совпадает, возвращает [point], нет nil
	private func checkI(_ point: Point, _ spot: Spot, _ centreSpot: Spot, _ nextPoint: NextPoint) -> [Point]? {
		let up = nextPoint(point, 1, .up)
		let down = nextPoint(point, 1, .down)
		if checkSpotCoordinate(up, .empty) &&
			checkSpotCoordinate(point, centreSpot) &&
			checkSpotCoordinate(down, .empty) {
			return [point]
		} else {
			return nil
		}
	}
	
	// up o o x down
	// где x - empty spot, o текущая точка, . spot  такого же типа как и o
	/// Проверяет xox во всех 8 направлениях. Если совпадает, возвращает [point], нет nil
	private func checkII(_ point: Point, _ spot: Spot, _ centreSpot: Spot, _ nextPoint: NextPoint) -> [Point]? {
		let up = nextPoint(point, 1, .up)
		let down = nextPoint(point, 1, .down)
		if checkSpotCoordinate(up, spot) &&
			checkSpotCoordinate(point, centreSpot) &&
			checkSpotCoordinate(down, .empty) {
			return [point, up]
		} else {
			return nil
		}
	}
	
	// up x o o down
	// где x - empty spot, o текущая точка, . spot  такого же типа как и o
	/// Проверяет xox во всех 8 направлениях. Если совпадает, возвращает [point], нет nil
	private func checkIII(_ point: Point, _ spot: Spot, _ centreSpot: Spot, _ nextPoint: NextPoint) -> [Point]? {
		let up = nextPoint(point, 1, .up)
		let down = nextPoint(point, 1, .down)
		if checkSpotCoordinate(up, .empty) &&
			checkSpotCoordinate(point, centreSpot) &&
			checkSpotCoordinate(down, spot) {
			return [point, down]
		} else {
			return nil
		}
	}
	
	// MARK: Rabbit all functions
	/// Проверка тройки в виде кролика
	private func checkThreeRabbit(point: Point, spot: Spot, setPoints: inout Set<Point>){
		rabbitAllFunctions(point: point, spot: spot, rabbitFunction: rabbitOne, setPoints: &setPoints)
		rabbitAllFunctions(point: point, spot: spot, rabbitFunction: rabbitTwo, setPoints: &setPoints)
		rabbitAllFunctions(point: point, spot: spot, rabbitFunction: rabbitThree, setPoints: &setPoints)
	}
	
	/// Каждый переданная функция rabbitFunction обрабатывается в 8 направлениях (функции check*)
	private func rabbitAllFunctions(point: Point, spot: Spot, rabbitFunction: RabbitFunction, setPoints: inout Set<Point>) {
		if let one = rabbitFunction(point, spot, checkOne) {
			setPoints = setPoints.union(one)
		}
		if let two = rabbitFunction(point, spot, checkTwo) {
			setPoints = setPoints.union(two)
		}
		if let three = rabbitFunction(point, spot, checkThree) {
			setPoints = setPoints.union(three)
		}
		if let four = rabbitFunction(point, spot, checkFour) {
			setPoints = setPoints.union(four)
		}
	}
	
	
	// MARK: Rabbit проверки
	// up x . . x o x down
	// где x - пусеой spot, o текущая точка, . spot  такого же типа как и o
	/// Провека ситуции когда точка пришлась в нижнюю точку следа кролика
	private func rabbitOne(point: Point, spot: Spot, nextPoint: NextPoint) -> [Point]? {
		guard var points = checkI(point, spot, .empty, nextPoint) else { return nil }
		
		// up +3
		let pointUp = nextPoint(point, 3, .up)
		if let pointsIII = checkIII(pointUp, spot, spot, nextPoint) {
			points.append(contentsOf: pointsIII)
			//return points
		}
		
		// down -3
		let pointDown = nextPoint(point, 3, .down)
		if let pointsII = checkII(pointDown, spot, spot ,nextPoint) {
			points.append(contentsOf: pointsII)
			return points
		}
		if points.count < 3 {
			return nil
		}
		return points
	}
	
	// up x . o x . x down   или   up x . x . o x down
	// где x - пусеой spot, o текущая точка, . spot  такого же типа как и o
	/// Провека ситуции когда точка пришлась в нижнюю точку следа кролика
	private func rabbitTwo(point: Point, spot: Spot, nextPoint: NextPoint) -> [Point]? {
		guard var points = checkII(point, spot, .empty, nextPoint) else { return nil }
		
		// up +3
		let pointUp = nextPoint(point, 3, .up)
		if let pointsI = checkI(pointUp, spot, spot, nextPoint) {
			points.append(contentsOf: pointsI)
		}
		
		// down +2
		let pointDownUp = nextPoint(point, 2, .up)
		if !checkSpotCoordinate(pointDownUp, .empty) { return nil }
		// down -2
		let pointDown = nextPoint(point, 2, .down)
		if let pointsI = checkI(pointDown, spot, spot, nextPoint) {
			points.append(contentsOf: pointsI)
			return points
		}
		if points.count < 3 {
			return nil
		}
		return points
	}
	
	// up x o . x . x down   или   up x . x o . x down
	// где x - пусеой spot, o текущая точка, . spot  такого же типа как и o
	/// Провека ситуции когда точка пришлась в нижнюю точку следа кролика
	private func rabbitThree(point: Point, spot: Spot, nextPoint: NextPoint) -> [Point]? {
		guard var points = checkIII(point, spot, .empty, nextPoint) else { return nil }
		
		// up -2
		let pointUpDown = nextPoint(point, 2, .down)
		if !checkSpotCoordinate(pointUpDown, .empty) { return nil }
		
		// up +2
		let pointUp = nextPoint(point, 2, .up)
		if let pointsI = checkI(pointUp, spot, spot, nextPoint) {
			points.append(contentsOf: pointsI)
			//return points
		}
		
		// down -3
		let pointDown = nextPoint(point, 3, .down)
		if let pointsI = checkI(pointDown, spot, spot, nextPoint) {
			points.append(contentsOf: pointsI)
			return points
		}
		if points.count < 3 {
			return nil
		}
		return points
	}
	
	// MARK: Проверка троек камней идущих подряд
	/// Проверка идущих подрят троеек
	private func checkThree(point: Point, spot: Spot, setPoints: inout Set<Point>) {
		if let one = checkThreeAll(point: point, spot: spot, nextPoint: checkOne) {
			setPoints = setPoints.union(one)
		}
		if let two = checkThreeAll(point: point, spot: spot, nextPoint: checkTwo) {
			setPoints = setPoints.union(two)
		}
		if let three = checkThreeAll(point: point, spot: spot, nextPoint: checkThree) {
			setPoints = setPoints.union(three)
		}
		if let four = checkThreeAll(point: point, spot: spot, nextPoint: checkFour) {
			setPoints = setPoints.union(four)
		}
	}

	/// Проверка двойных троек по всех 8 направлениям.
	private func checkThreeAll(point: Point, spot: Spot, nextPoint: NextPoint) -> Set<Point>? {
		var points = Set<Point>()
		var index = 4;
		var summa = 0
		for i in 1...index {
			let up = nextPoint(point, i, .up)
			let weight = getWeightOfSpor(point: up, spot: spot)
			index -= 1
			summa += weight.rawValue
			if weight == .current {
				points.insert(up)
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
				points.insert(down)
			} else {
				break
			}
		}
		if summa == 4 {
            points.insert(point)
            return points
		} else {
			return nil
		}
	}
	
	// MARK: Проверка пяти подряд идущих камней.
	/// Проверяет подряд идущие камни, во всех 8 направлениях на доске.
	func checkWinerToFiveSpots(point: Point, stone: Stone) -> Bool {
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
	private func checkFiveAll(point: Point, spot: Spot, nextPoint: NextPoint) -> Bool {
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

extension Board {
	
	/// Возврат кортежа весов в белого и четрно
	static func getWeightWhiteBlack(weight: Weight) -> (Weight, Weight) {
		return ((weight >> 8) & 0xff, weight & 0xff)
	}
}
