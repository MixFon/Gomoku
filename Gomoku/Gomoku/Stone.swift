//
//  Stone.swift
//  Gomoku
//
//  Created by Михаил Фокин on 18.11.2021.
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
	
	init?(spot: Board.Spot) {
		switch spot {
		case .black:
			self = .black
		case .white:
			self = .white
		default:
			return nil
		}
	}
}
