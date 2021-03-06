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
	private let keyPathSaveFileJSON = "keyPathSaveFileJSON"
	private let nameSaveFolder = "SavesGomoku"
	private let nameSaveFileJSON = "saves.json"
	
	weak var delegate: GetProtocol!
	
	/// Сохранение координат в файле.
	func saving() {
		if !preparingSave() { return }
		guard let pathJSON = getPathSaveFileJSON() else { return }
		guard var saves = getSaves() else { return }
		guard let newSave = fillSave(number: saves.count) else { print("Error save image");return }
		saves.append(newSave)
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		guard let data = try? encoder.encode(saves) else { print("error encode"); return }
		do {
			try data.write(to: URL(fileURLWithPath: pathJSON))
		} catch {
			print("Saving error.")
		}
	}
	
	/// Заполняет структуру сохранения.
	private func fillSave(number: Int) -> Save? {
		guard let pathFolder = getPathSaveFolder() else { return nil }
		var urlFolder = URL(fileURLWithPath: pathFolder)
		print(pathFolder)
		guard let image = self.delegate.getSnapshop() else { return nil }
		var save = Save()
		save.name = "save_\(number)"
		urlFolder.appendPathComponent(save.name ?? "image")
		urlFolder.appendPathExtension("png")
		if !image.writeToFile(file: urlFolder.standardizedFileURL, atomically: true, usingType: .png){return nil }
		save.pathImage = urlFolder.path
		
		save.date = Date().getStringDate()
		
		save.mode = self.delegate.getMode()
		
		// Получение информации с доски
		let board = self.delegate.getBoard()
		
		save.board = board.getBoard()
		
		save.bestPointWhite = board.getBestPointWhite()
		save.bestPointBlack = board.getBestPointBlack()
		
		save.pointsDoubleThree = board.getPointsDoubleThree()
		
		save.pointsCapturesBlack = board.getPointsCapturesBlack()
		
		save.stone = board.getCurrentSpotString()
		
		save.whiteCaptures = board.getWhiteCaptures()
		save.blackCaptures = board.getBlackCaptures()
		return save
	}

	/// Открывает файл json и переводит его в массив сохранений.
	func getSaves() -> [Save]? {
		let decoter = JSONDecoder()
		decoter.keyDecodingStrategy = .convertFromSnakeCase
		guard let pathJSON = getPathSaveFileJSON() else { return nil }
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: pathJSON))
			return try decoter.decode([Save].self, from: data)
		} catch  {
			print("Error reading the file {\(pathJSON)}")
		}
		return []
	}
	
	/// Подготовка к сохранению. Создает папку и файл сохранения. ture - успех создания
	private func preparingSave() -> Bool {
		var pathSaveFolder = getPathSaveFolder()
		if pathSaveFolder == nil {
			guard let path = createSaveFolder() else { return false }
			setValueUserDeafaults(value: path, kye: self.keyPathSaveFolder)
			pathSaveFolder = path
			print("create", pathSaveFolder ?? "NIL")
		}
		guard let pathFolder = pathSaveFolder else { return false }
		let pathSaveFileJSON = "\(pathFolder)/\(self.nameSaveFileJSON)"
		if !createFile(path: pathSaveFileJSON) {
			print("Error create file \(pathSaveFileJSON)")
			return false
		}
		setValueUserDeafaults(value: pathSaveFileJSON, kye: self.keyPathSaveFileJSON)
		return true
	}
	
	/// Установить указанное значение в UD по заданному ключу
	private func setValueUserDeafaults(value: String, kye: String) {
		let userDefaults = UserDefaults.standard
		userDefaults.set(value, forKey: kye)
	}
	
	/// Возвращает путь до папки сохранения
	private func getPathSaveFolder() -> String? {
		let userDefaults = UserDefaults.standard
		return userDefaults.string(forKey: self.keyPathSaveFolder)
	}
	
	/// Возвращает путь до файла сохранения
	private func getPathSaveFileJSON() -> String? {
		let userDefaults = UserDefaults.standard
		return userDefaults.string(forKey: self.keyPathSaveFileJSON)
	}
	
	/// Создание файла по указанному пути
	private func createFile(path: String) -> Bool {
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: path) {
			return fileManager.createFile(atPath: path, contents: nil, attributes: nil)
		}
		return true
	}
	
	/// Создание папки сохранения.
	private func createSaveFolder() -> String? {
		let fileManager = FileManager.default
		let homeDirectory = "\(NSHomeDirectory())/\(self.nameSaveFolder)"
		do {
			if !fileManager.fileExists(atPath: homeDirectory) {
				try fileManager.createDirectory(atPath: homeDirectory, withIntermediateDirectories: false, attributes: nil)
			}
		} catch {
			print("Error create directory \(homeDirectory)")
			return nil
		}
		return homeDirectory
	}
}

extension NSImage {
	func writeToFile(file: URL, atomically: Bool, usingType type: NSBitmapImageRep.FileType) -> Bool {
		guard
			let imageData = tiffRepresentation,
			let imageRep = NSBitmapImageRep(data: imageData),
			let fileData = imageRep.representation(using: type, properties: [.compressionFactor : 0.6]) else {
				return false
		}
		do {
			try fileData.write(to: file)
		} catch  {
			return false
		}
		return true
	}
}

extension Date {
	func getStringDate() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YY, MMM d, hh:mm"
		return dateFormatter.string(from: self)
	}
}
