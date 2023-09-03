//
//  CmdUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

/// Executes a command in the shell and prints the output to the
/// console.
///
/// - Parameters:
///    - command: The command to be executed in the shell
///
/// - Throws: An error if there was a problem executing the
/// command or reading from the pipe
func shell(_ command: Game) throws {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command.launcher]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil
    logger.write(
        "[INFO]: Executing command: \(task.arguments!.joined(separator: " ")) to launch game: \(command.name)."
    )
    try task.run()

    pipe.fileHandleForReading.readabilityHandler = { fileHandle in
        guard let line = String(data: fileHandle.availableData, encoding: .utf8) else { return }
        print(line, terminator: "")
    }
}

func quitGame(_ gameName: String) throws {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", "pkill \(gameName)"]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil
    logger.write(
        "[INFO]: Executing command: \(task.arguments!.joined(separator: " ")) to quit game: \(gameName)."
    )
    try task.run()

    pipe.fileHandleForReading.readabilityHandler = { fileHandle in
        guard let line = String(data: fileHandle.availableData, encoding: .utf8) else { return }
        print(line, terminator: "")
    }
}
