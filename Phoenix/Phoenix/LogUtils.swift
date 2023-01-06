//
//  LogUtils.swift
//  Phoenix
//
//  Created by guru on 1/5/23.
//
import Foundation

var logger = ConsoleAndFileLogger()
/// A logger that writes to both the console and a log file.
struct ConsoleAndFileLogger: TextOutputStream {
  let logFileHandle: FileHandle
  let dateFormatter: DateFormatter

  init() {
    let logDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first!.appendingPathComponent("Phoenix", isDirectory: true)

    // Set up the date formatter
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"

    let timestamp = dateFormatter.string(from: Date())
    let logFileURL = logDir.appendingPathComponent("log_\(timestamp).log")

    // Create the log directory if it doesn't exist
    try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)

    // Create the log file if it doesn't exist
    if !FileManager.default.fileExists(atPath: logFileURL.path) {
      FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
    }

    // Open the log file for writing
    logFileHandle = try! FileHandle(forWritingTo: logFileURL)
    logFileHandle.seekToEndOfFile()
  }

  mutating func write(_ string: String) {
    let timestamp = dateFormatter.string(from: Date())
    let logString = "\(timestamp) Phoenix: \(string)\n"
    print(logString, terminator: "")
    logFileHandle.write(logString.data(using: .utf8)!)
  }
}
