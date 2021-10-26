//
//  SaveManager.swift
//  Gamoku
//
//  Created by Михаил Фокин on 25.10.2021.
//

import Foundation
import AppKit

class SaveManager {
	
	private let keyURLSaveFolder = "keyURLSaveFolder"
	private let nameSaveFolder = "SavesGomoku"
	private let nameSaveFileJSON = "saves.json"
	
	/// Сохранение координат в файле.
	func saving(whiteStones:[Point], blackStone: [Point]) {
		let userDefaults = UserDefaults.standard
		//userDefaults.removeObject(forKey: self.keyURLSaveFolder)
		let urlSaveFolder = userDefaults.object(forKey: self.keyURLSaveFolder) as? URL
		if urlSaveFolder == nil {
			guard let url = createSaveFolder() else { return }
			userDefaults.set(url, forKey: self.keyURLSaveFolder)
			print("create", url.absoluteURL)
		}
		print(urlSaveFolder?.absoluteURL ?? "Nil")
	}
	
	/// Создание папки сохранения.
	private func createSaveFolder() -> URL? {
		let fileManager = FileManager.default
		let homeDirectory = "\(NSHomeDirectory())/\(self.nameSaveFolder)"
		do {
			if !fileManager.fileExists(atPath: homeDirectory) {
				try fileManager.createDirectory(atPath: homeDirectory, withIntermediateDirectories: false, attributes: nil)
			}
		} catch {
			print("Error create directory.")
			return nil
		}
		return URL(fileURLWithPath: homeDirectory)
	}
	
	/// Возвращает URL папки сохранения из домашней дериктории пользователя
//	private func getURL() -> URL? {
//
//	}
	/*
	if !fileManager.fileExists(atPath: url.absoluteString) {
		fileManager.createFile(atPath: url.absoluteString, contents: nil, attributes: nil)
	}
	*/
	
}

/*
var save = Save()
save.name = "first"
save.date = Date()
save.blackPoints =
save.whiteStones = [Point(2, 2)]
*/
