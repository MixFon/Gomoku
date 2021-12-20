//
//  Enams.swift
//  Gomoku
//
//  Created by Михаил Фокин on 09.12.2021.
//

import Foundation

/// Имена картинок камней
enum NamesImage: String {
	case whiteStone = "white_stone"
	case blackStone = "black_stone"
}

/// ID Sourybouard и ID ViewController
enum Identifier: String {
	case startMenu = "3DMenuID"
	case gameVC = "GameVC"
	case loadingSB = "DounloadSourybouard"
	case loadingVC = "Download"
}
