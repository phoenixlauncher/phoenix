//
//  JsonUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation
import SwiftUI

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

func getGameNames() {
    let fileManager = FileManager.default
    let steamAppsDirectory = URL(fileURLWithPath: "~/Library/Application Support/Steam/steamapps", isDirectory: true)
    // Create an NSOpenPanel instance
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.directoryURL = steamAppsDirectory
    openPanel.prompt = "Select"
    
    print("inside getGameNames()")
    // Show the open panel
    if openPanel.runModal() == .OK {
        print("after modal select")
        do {
            let appIDDirectories = try fileManager.contentsOfDirectory(at: openPanel.url!, includingPropertiesForKeys: nil)
            var games = [Game]()
            for appIDDirectory in appIDDirectories {
                let appID = appIDDirectory.lastPathComponent
                if appID.hasSuffix(".acf") {
                    let manifestFilePath = appIDDirectory
                    let manifestFileData = try Data(contentsOf: manifestFilePath)
                    let manifestDictionary = parseACFFile(data: manifestFileData)
                    let name = manifestDictionary["name"]
                    let numberedAppID = manifestDictionary["appid"]
                    let game = Game(
                        appID: numberedAppID ?? "Unknown",
                        launcher: "open steam://run/\(numberedAppID ?? "Unknown")",
                        metadata: [
                            "rating": "",
                            "release_date": "",
                            "time_played": "",
                            "last_played": "",
                            "developer": "",
                            "header_img": "",
                            "description": "",
                            "genre": "",
                            "publisher": ""
                        ],
                        icon: "PlaceholderIcon",
                        name: name ?? "Unknown",
                        platform: Platform.STEAM
                    )
                    print(game)
                    games.append(game)
                }
            }
            let gamesList = GamesList(games: games)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(gamesList) {
                if let jsonString = String(data: encoded, encoding: .utf8) {
                    writeGamesToJSON(data: jsonString)
                }
            }
        } catch {
            print("Error: Failed to read SteamApps directory at \(openPanel.url!)")
        }
    } else {
        print("Access denied")
    }
}

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
