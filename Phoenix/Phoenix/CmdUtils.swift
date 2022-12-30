//
//  CmdUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

//@discardableResult // Add to suppress warnings when you don't want/need a result
func shell(_ command: String) throws {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil
    
    try task.run()
    
    pipe.fileHandleForReading.readabilityHandler = { fileHandle in
        guard let line = String(data: fileHandle.availableData, encoding: .utf8) else { return }
        print(line, terminator: "")
    }
}
