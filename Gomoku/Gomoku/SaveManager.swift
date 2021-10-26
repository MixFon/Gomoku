//
//  SaveManager.swift
//  Gamoku
//
//  Created by Михаил Фокин on 25.10.2021.
//

import Foundation
import AppKit

class SaveManager {
	
	private let keyPathSaveFolder = "keyPathSaveFolder"
	private let saveFolder = "SavesGomoku"
	private let saveFileJSON = "saves.json"
	
	/// Сохранение координат в файле.
	func saving(whiteStones:[Point], blackStone: [Point]) {
		let userDefaults = UserDefaults.standard
		userDefaults.removeObject(forKey: self.keyPathSaveFolder)
		let pathSaveFolder = userDefaults.object(forKey: self.keyPathSaveFolder) as? String
		if pathSaveFolder == nil {
			guard let url = createSaveFolder() else { return }
			userDefaults.set(url, forKey: self.keyPathSaveFolder)
			print("create", url.absoluteURL)
		}
		print("!!!", pathSaveFolder)
	}
	
	/// Создание папки сохранения.
	private func createSaveFolder() -> URL? {
		let fileManager = FileManager.default
		
		//guard var url = fileManager.urls(for: .userDirectory, in: .userDomainMask).first else { return nil }
		let homeDirectory = "\(NSHomeDirectory())/\(self.saveFolder)"
//		var url = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		do {
			//try fileManager.url(for: .userDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			//url.appendPathComponent(self.saveFolder)
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
