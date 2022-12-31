//
//  JsonUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation
import SwiftUI

/**
 Returns the URL for the application support directory for the current user.
 
 - Returns: The URL for the application support directory.
 */
private func getApplicationSupportDirectory() -> URL {
    // find all possible Application Support directories for this user
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    
    // just send back the first one, which ought to be the only one
    return paths[0]
}


func parseACFFile(data: Data) -> [String: String] {
    let string = String(decoding: data, as: UTF8.self)
    
    // Use a regular expression to extract the key-value pairs
    let pattern = "(\"[^\"]+\"\\s*\"[^\"]*\")"
    let regex = try! NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in: string, range: NSRange(location: 0, length: string.count))
    
    // Split the matches into key-value pairs and add them to the dictionary
    var dict = [String: String]()
    for match in matches {
        let keyValueString = (string as NSString).substring(with: match.range)
        let keyValueArray = keyValueString.components(separatedBy: "\"")
        let key = keyValueArray[1]
        let value = keyValueArray[3]
        dict[key] = value
    }
    
    return dict
}

func getGameNames() -> some View {
    let fileManager = FileManager.default
    let steamAppsDirectory = URL(fileURLWithPath: "~/Library/Application Support/Steam/steamapps", isDirectory: true)
    
    // Create an NSOpenPanel instance
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.directoryURL = steamAppsDirectory
    openPanel.prompt = "Select"
    
    // Show the open panel
    if openPanel.runModal() == .OK {
        do {
            let appIDDirectories = try fileManager.contentsOfDirectory(at: openPanel.url!, includingPropertiesForKeys: nil)
            var gameNames = ""
            for appIDDirectory in appIDDirectories {
                let appID = appIDDirectory.lastPathComponent
                if appID.hasSuffix(".acf") {
                    let manifestFilePath = appIDDirectory
                    let manifestFileData = try Data(contentsOf: manifestFilePath)
                    let manifestDictionary = parseACFFile(data: manifestFileData)
                    if let appName = manifestDictionary["name"] {
                        gameNames += appName + "\n"
                    }
                }
            }
            print("gameNames:")
            print(gameNames)
            return Text(gameNames)
        } catch {
            print("Error: Failed to read SteamApps directory at \(openPanel.url!)")
            return Text("Error: Failed to read SteamApps directory")
        }
    } else {
        return Text("Access denied")
    }
}

/**
 Loads the games data from a JSON file named "games.json" in the "Phoenix"
 directory under the application support directory.
 
 - Returns: A `GamesList` object containing the games data (Empty if none can be
 read from "games.json".
 
 - Throws: An error if there was a problem reading from the JSON file or
 decoding the data.
 */
func loadGamesFromJSON() -> GamesList {
    let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
    // log to console the path to the file
    print("Loading games from: \(url.path)")
    
    var games: GamesList?
        do {
            let jsonData = try Data(contentsOf: url)
            games = try JSONDecoder().decode(GamesList.self, from: jsonData)
    
            return games ?? GamesList(games: [])
        } catch {
            print("Couldn't find games.json. Creating new one.")
            let jsonFileURL = Bundle.main.url(forResource: "games", withExtension: "json")
            do {
                let jsonData = try Data(contentsOf: jsonFileURL!)
                let jsonString = String(decoding: jsonData, as: UTF8.self)
                writeGamesToJSON(data: jsonString)
            } catch {
                print("Could not get data from 'games.json'")
            }
            
            do {
                let jsonData = try Data(contentsOf: url)
                games = try JSONDecoder().decode(GamesList.self, from: jsonData)
                
                return games ?? GamesList(games: [])
            } catch {
                print("Couldn't read from new 'games.json'")
            }
        }
    
        return GamesList(games: [])
}

/**
 Writes the given data to a JSON file named "games.json" in the "Phoenix"
 directory under the application support directory.
 
 - Parameters:
    - data: The data to write to the JSON file.
 
 - Returns: Void.
 
 - Throws: An error if there was a problem creating the directory or file, or
           writing to the file.
 */
func writeGamesToJSON(data: String) {
    // If .../Application Support/Phoenix directory exists
    if FileManager.default.fileExists(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix", isDirectory: true).path) {
        // If .../Application Support/Phoenix/games.json file exists
        if FileManager.default.fileExists(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json", conformingTo: .json).path) {
            let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
            do {
                try data.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                print("Could not write data to 'games.json'")
            }
        // If .../Application Support/Phoenix/games.json file DOESN'T exist
        } else {
            if FileManager.default.createFile(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json", conformingTo: .json).path, contents: Data(data.utf8)) {
                print("'games.json' created successfully.")
            } else {
                print("'games.json' not created.")
            }
        }
        // If .../Application Support/Phoenix/cachedImages DOESN'T exist
        if FileManager.default.fileExists(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/cachedImages", isDirectory: true).path) {
            do {
                try FileManager.default.createDirectory(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix", conformingTo: .directory).path, withIntermediateDirectories: true)
            } catch {
                print("Could not create directory")
            }
        }
    // If .../Application Support/Phoenix directory DOESN'T exist
    } else {
        do {
            try FileManager.default.createDirectory(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix", conformingTo: .directory).path, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/cachedImages", conformingTo: .directory).path, withIntermediateDirectories: true)
            
            if FileManager.default.createFile(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json", conformingTo: .json).path, contents: Data(data.utf8)) {
                print("'games.json' created successfully.")
            } else {
                print("'File' not created.")
            }
        } catch {
            print("Could not create directory")
        }
    }
    
    
}
