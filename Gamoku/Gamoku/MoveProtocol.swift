//
//  MoveProtocol.swift
//  Gamoku
//
//  Created by Михаил Фокин on 19.10.2021.
//

import Foundation
import SceneKit

protocol MoveProtocol: AnyObject {
	func moving(point: Point, stone: Stone)
	func delete(points: (Point, Point), stone: Stone)
	func pinShine(point: Point, color: NSColor)
}
