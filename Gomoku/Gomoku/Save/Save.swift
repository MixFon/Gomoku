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
	var stone: String?
	var whiteCaptures: Int?
	var blackCaptures: Int?
	var whitePoints: [Point]?
	var blackPoints: [Point]?
	
}