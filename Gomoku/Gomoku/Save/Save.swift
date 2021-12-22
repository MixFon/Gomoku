//
//  Save.swift
//  Gamoku
//
//  Created by Михаил Фокин on 25.10.2021.
//

import Foundation

struct Save: Codable {
	var mode: String?
	var name: String?
	var date: String?
	var pathImage: String?
	var board: [[Board.Weight]]?
	var bestPointWhite: Board.BestPoint?
	var bestPointBlack: Board.BestPoint?
	var pointsDoubleThree: Set<Point>?
	var pointsCapturesBlack: Set<Point>?
    var pointsCapturesWhite: Set<Point>?
	var stone: String?
	var whiteCaptures: Int?
	var blackCaptures: Int?
}
