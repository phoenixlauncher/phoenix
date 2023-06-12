//
//  LogUtils.swift
//  Phoenix
//
//  Created by guru on 1/5/23.
//
import Foundation

var logger = ConsoleAndFileLogger()
/// A logger that writes to both the console and a log file. There are a maximum of 3 log files created. The oldest log is deleted after the number of log files surpasses 3.
struct ConsoleAndFileLogger: TextOutputStream {
    let logFileHandle: FileHandle
    let dateFormatter: DateFormatter

    init() {
        let logDir = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        )
        .first!.appendingPathComponent("Phoenix", isDirectory: true)

        // Set up the date formatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"

        // Create the log directory if it doesn't exist
        try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)

        // Delete old log files if there are more than 3
        let logFileURLs = try? FileManager.default.contentsOfDirectory(
            at: logDir, includingPropertiesForKeys: nil)
        if logFileURLs != nil && logFileURLs!.count > 3 {
            let sortedLogFileURLs = logFileURLs!.sorted(by: { url1, url2 -> Bool in
                let file1Attributes = try? FileManager.default.attributesOfItem(atPath: url1.path)
                let file2Attributes = try? FileManager.default.attributesOfItem(atPath: url2.path)
                let file1ModificationDate =
                    file1Attributes![FileAttributeKey.modificationDate] as! Date
                let file2ModificationDate =
                    file2Attributes![FileAttributeKey.modificationDate] as! Date
                return file1ModificationDate.compare(file2ModificationDate) == .orderedAscending
            })

            for url in sortedLogFileURLs[0..<sortedLogFileURLs.count - 3] {
                let fileExtension = url.pathExtension
                if fileExtension == "log" {
                    try! FileManager.default.removeItem(at: url)
                }
            }
        }

        // Create a new log file
        let timestamp = dateFormatter.string(from: Date())
        let logFileURL = logDir.appendingPathComponent("log_\(timestamp).log")
        FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)

        // Open the log file for writing
        logFileHandle = try! FileHandle(forWritingTo: logFileURL)
        logFileHandle.seekToEndOfFile()
    }

    /// Write function for logger which takes in a String, prints string as well as writing to file
    mutating func write(_ string: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logString = "\(timestamp) Phoenix: \(string)\n"
        print(logString, terminator: "")
        logFileHandle.write(logString.data(using: .utf8)!)
    }
}
