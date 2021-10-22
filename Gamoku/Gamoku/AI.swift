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
	let errorPipe = Pipe()
	init() throws {
		
		//task.executableURL = URL(fileURLWithPath: "/Users/mixfon/TaskmasterTasks")
		//task.arguments = ["/Users/mixfon/MyFiles/Swift/Gomoku/Gamoku/AI/AI.py"]
		
		self.task.executableURL = URL(fileURLWithPath: "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3")
		//self.task.executableURL = URL(fileURLWithPath: "/usr/bin/say")
			
		self.task.arguments = ["/Library/Frameworks/Python.framework/Versions/3.7/bin/AI2.py"]
		//self.task.arguments = ["Hello Ira Ira Ira Ira Ira Ira Ira Ira Ira Ira Ira Ira Ira IraIra Ira "]
			self.task.standardInput = self.inputPipe
			self.task.standardOutput = self.outputPipe
			self.task.standardError = self.errorPipe
			
//			self.outputPipe.fileHandleForReading.readabilityHandler = { pipe in
//				let line = String(decoding: pipe.availableData, as: UTF8.self)
//					// Update your view with the new text here
//					print("New ouput: \(line)")
//			}
		//let queue = DispatchQueue.global(qos: .background)
		//queue.async{
			try self.task.run()
		//}
		//print(ai.getRequest(message: "temp"), "!!!")
//		let outputData = self.outputPipe.fileHandleForReading.readDataToEndOfFile()
//		let errorData = self.errorPipe.fileHandleForReading.readDataToEndOfFile()
//		let output = String(decoding: outputData, as: UTF8.self)
//		let error = String(decoding: errorData, as: UTF8.self)
//		print(output + error)
	}
	
	func getRequest(message: String) -> String {
		let outputData = self.outputPipe.fileHandleForReading.readData(ofLength: 10)
		//let errorData = self.errorPipe.fileHandleForReading.readData(ofLength: 10)
		let output = String(decoding: outputData, as: UTF8.self)
		//let error = String(decoding: errorData, as: UTF8.self)
		return output
	}
}
