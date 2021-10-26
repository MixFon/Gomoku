//
//  Point.swift
//  Gamoku
//
//  Created by Михаил Фокин on 20.10.2021.
//

import Foundation

struct Point: Codable {
	var x = 0
	var y = 0
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}

extension Point: Equatable {
	static func == (left: Point, right: Point) -> Bool {
		return (left.x == right.x) && (left.y == right.y)
	}
}
