//
//  Gomoku.swift
//  Gamoku
//
//  Created by Михаил Фокин on 19.10.2021.
//

import Foundation
import AppKit

class Gomoku {
	var ai = AI()
	
	private var mode = Mode.pvp
	
	private var board = Board()
	
	weak var delegate: MoveProtocol?
	
	private var stone = Stone.white
	
	private var winningPoint: PointStone?
	
	let numberCapturesToWin: Int = 5
	
	var makeSnapshot: (()->NSImage?)?
	
	enum Mode: String {
		case pvp
		case pvc
	}
	
	/// Точка при которой образуется победитель. Целостность 5-ти камней не должна быть нарушна следующим ходом.
	struct PointStone {
		let point: Point
		let stone: Stone
	}
	
	/// Вызывается при закрузке сохраненной игры. На доске устанавливаются нужные spots
	func setStartPointOnBouard() {
		self.board.printBourd()
		for pointStone in board.getPointStones() {
			delegate?.moving(point: pointStone.point, stone: pointStone.stone)
		}
	}
	
	/// Установка делегата на Board им должен быть GameViewController
	func setDelegateToBoard(delegate: MoveProtocol) {
		self.board.setDelegate(delegate: delegate)
	}
	
	/// Установка доски.
	func setBoard(board: Board) {
		self.board = board
	}
	
	/// Следующий ход. Может быть как ход PvP так и PvC. В зависимости от типа игры.
	func nextMove(point: Point) {
		if movePalyer(point: point, stone: self.stone) {
			self.delegate?.pinShine(point: point, color: .green)
			if self.mode == .pvc {
				moveAI()
			} else {
				self.stone = self.stone.opposite()
			}
		} else {
			self.delegate?.pinShine(point: point, color: .red)
		}
	}
	
	/// Устанавливает камень, который должен ходить следеющим. Устанавливат на основе доски
	func setCurrentStone() {
		if let stone = Stone(rawValue: Character(self.board.getCurrentSpotString())) {
			self.stone = stone
		}
	}
	
	/// Установка режима игры
	func setMode(mode: Mode) {
		self.mode = mode
	}
	
	/// Ход ИИ
	private func moveAI() {
		let bestPoints = getStartBestBlackPoints(board: self.board)
		if bestPoints.isEmpty { return }
		let start = DispatchTime.now()
		guard let point = ai.startMinimax(board: self.board, allPoints: bestPoints) else { return }
		let end = DispatchTime.now()
		let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
		let timeInterval = Double(nanoTime) / 1_000_000_000
		self.delegate?.showTime(time: "\(timeInterval)")
		self.board.setCurrentSpotToPoint(point: point)
		let globalPoint = self.board.convertCoordinateToGlobal(point: point)
		self.delegate?.moving(point: globalPoint, stone: .black)
		checkWinerToFiveStones(point: globalPoint, stone: .black)
		checkWinerToCapture()
		self.board.printBourd()
	}
	
	/// Возвращает массив лучших черных точек для доски
	private func getStartBestBlackPoints(board: Board) -> [Point] {
		var bestBlackPoints = [Point]()
		let boardWeight = board.getBoard()
		for (i, line) in boardWeight.enumerated() {
			for (j, element) in line.enumerated() {
				if element != 0x0 && element != 0x1 && element != 0x100 && element != 0x404{
					bestBlackPoints.append(Point(i, j))
				}
			}
		}
		bestBlackPoints.sort(by: {
								let (_ , b1) = Board.getWeightWhiteBlack(weight: boardWeight[$0.x][$0.y])
								let (_ , b2) = Board.getWeightWhiteBlack(weight: boardWeight[$1.x][$1.y])
								return b1 > b2 }
		)
		if bestBlackPoints.isEmpty { return [] }
		return Array(bestBlackPoints[0...])
	}
	
	/// Ход игрока
	private func movePalyer(point: Point, stone: Stone) -> Bool {
		if !self.board.placeStone(point: point, stone: stone) {
			return false
		}
		self.delegate?.moving(point: point, stone: stone)
		checkWinerToFiveStones(point: point, stone: stone)
		return true
	}
	
	/// Проверка победителя по выставлении 5 камней в ряд. В случае победы все сбрасывается.
	/// Игрок выставивший 5 камней подряд побеждает только когда следующийм ходом нельзя нарушить целостность 5 камней.
	private func checkWinerToFiveStones(point: Point, stone: Stone) {
		if let winnigPoint = self.winningPoint {
			if self.board.checkWinerToFiveSpots(point: winnigPoint.point, stone: winnigPoint.stone) {
				self.delegate?.showingWinner(stone: winnigPoint.stone)
				self.reset()
			} else {
				self.winningPoint = nil
			}
		} else if self.board.checkWinerToFiveSpots(point: point, stone: stone) {
			self.winningPoint = PointStone(point: point, stone: stone)
		}
	}
	
	/// Проверка победител по захвату. Для победы нужно провести 5 захватов
	private func checkWinerToCapture() {
		if self.board.getWhiteCaptures() >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .white)
			print("Win Captures!!!!")
			reset()
		} else if self.board.getBlackCaptures() >= self.numberCapturesToWin {
			self.delegate?.showingWinner(stone: .black)
			print("Win Captures!!!!")
			reset()
		}
	}
	
	/// Сбразыватеся до начальных настроек
	private func reset() {
		self.winningPoint = nil
		self.board = Board()
		self.board.delegate = self.delegate
		self.stone = .white
		self.ai = AI()
	}
	
	/// Сохранение состояния доски и сохранение изображения
	func saving() {
		let saveManager = SaveManager()
		saveManager.delegate = self
		saveManager.saving()
	}
}

// MARK: GetProtocol
extension Gomoku: GetProtocol {
	
	/// Возвращает текушую доску.
	func getBoard() -> Board {
		return self.board
	}
	
	/// Возвращает камень, который должен ходить следеющим
	func getStone() -> String {
		return String(self.stone.rawValue)
	}
	
	/// Возвращает текущий режим игры
	func getMode() -> String {
		return self.mode.rawValue
	}
	
	/// Возвращает моментальный снимок экрана
	func getSnapshop() -> NSImage? {
		return self.makeSnapshot?()
	}
}
