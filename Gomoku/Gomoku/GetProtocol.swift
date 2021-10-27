//
//  SnapshotProtocol.swift
//  Gomoku
//
//  Created by Михаил Фокин on 26.10.2021.
//

import Foundation
import AppKit

protocol GetProtocol: AnyObject  {
	func getSnapshop() -> NSImage?
	func getPointsWhiteStonesOnBoard() -> [Point]
	func getPointsBlackStonesOnBoard() -> [Point]
	func getMode() -> String
	func getStone() -> String
}
