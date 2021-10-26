//
//  Save.swift
//  Gamoku
//
//  Created by Михаил Фокин on 25.10.2021.
//

import Foundation

struct Save: Codable {
	private var name: String?
	private var date: Date?
	private var whiteStones: [Point]?
	private var blackPoints: [Point]?
}
