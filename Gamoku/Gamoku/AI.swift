//
//  AI.swift
//  Gamoku
//
//  Created by Михаил Фокин on 22.10.2021.
//

import Foundation

class AI {
	var task = Process()
	let inputPipe = Pipe()
	let outputPipe = Pipe()
	
	private let pathonPath = "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3"
	private let scriptAIPath = "/Library/Frameworks/Python.framework/Versions/3.7/bin/AI.py"
	
	init() throws {
		self.task.executableURL = URL(fileURLWithPath: self.pathonPath)
		self.task.arguments = [self.scriptAIPath]
		self.task.standardInput = self.inputPipe
		
		self.task.standardOutput = self.outputPipe
		self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
		  
		NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: self.outputPipe.fileHandleForReading , queue: nil) { notification in
			
			let outputData = self.outputPipe.fileHandleForReading.availableData
			guard let outputString = String(data: outputData, encoding: .utf8) else { return }
			
			//5.
			print(outputString, "111")
			if outputString.isEmpty {
				return
			}
			
			DispatchQueue.main.async(execute: {
				// какие-то действия с UI в главном потоке.
			})
			self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
		}
		try self.task.run()
	}
	
	/// Отправляет запрос дочернему процессу в стандартный поток ввода.
	func getRequestToAI(message: String) {
		if let data = message.data(using: .utf8) {
			self.inputPipe.fileHandleForWriting.write(data)
		}
	}
}
