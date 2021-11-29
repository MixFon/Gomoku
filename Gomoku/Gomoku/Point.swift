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
	
	/// Возвращет true, если x или y координата павна отрицательнома числу.
	func isNegativeCoordinates() -> Bool {
		return self.x < 0 || self.y < 0
	}
}

extension Point: Equatable, Hashable {
	static func == (left: Point, right: Point) -> Bool {
		return (left.x == right.x) && (left.y == right.y)
	}
	
	func hash(into hasher: inout Hasher) {
		  hasher.combine(x)
		  hasher.combine(y)
	  }
}
