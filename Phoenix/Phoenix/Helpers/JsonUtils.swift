//
//  JsonUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation
import SwiftyJSON

/// Returns the URL for the application support directory for the current user.
///
/// - Returns: The URL for the application support directory.
func getApplicationSupportDirectory() -> URL {
    // find all possible Application Support directories for this user
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}

/// Returns the Phoenix application support directory
///
/// - Returns: The URL for the Application support directory/Phoenix.
func getPhoenixDirectory() -> URL? {
    let fileManager = FileManager.default
    let appSupportDirectory = fileManager.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
    )
    .first
    let phoenixDirectory = appSupportDirectory?.appendingPathComponent("Phoenix")
    return phoenixDirectory
}

///  Parses the appmanifest_<steamID>.acf file and returns a dictionary of the key-value pairs.
///
///    - Parameters:
///      - data: The data from the appmanifest_<steamID>.acf file.
///
///    - Returns: A dictionary of the key-value pairs.
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

/// Loads the games data from a JSON file named "games.json" in the "Phoenix"
/// directory under the application support directory.
///
/// - Returns: A `GamesList` object containing the games data (Empty if none can be
/// read from "games.json".
///
/// - Throws: An error if there was a problem reading from the JSON file or
/// decoding the data.
func loadGamesFromJSON() -> [Game] {
    let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
    var games: [Game] = []
    if let json = try? JSON(data: Data(contentsOf: url)) {
        let gamesArray = json["games"].arrayValue
        for game in gamesArray {
            var platformString = ""
            if game["platform"].string == nil {
                platformString = game["platformName"].stringValue
            } else {
                platformString = game["platform"].stringValue
                if platformString == "mac" {
                    platformString = "Mac"
                } else if platformString == "steam" {
                    platformString = "Steam"
                } else if platformString == "gog" {
                    platformString = "GOG"
                } else if platformString == "pc" {
                    platformString = "PC"
                } else if platformString == "ps" {
                    platformString = "Playstation"
                } else if platformString == "xbox" {
                    platformString = "Xbox"
                } else if platformString == "nin" {
                    platformString = "Nintendo"
                }
            }
            let gameFile = (game["gameFile"].stringValue != "" ? game["gameFile"].stringValue : (game["launcher"].stringValue.range(of: #""([^"]+)""#, options: .regularExpression) != nil) ? String(game["launcher"].stringValue[game["launcher"].stringValue.range(of: #""([^"]+)""#, options: .regularExpression)!].dropFirst().dropLast()) : "")
            games.append(Game(
                id: UUID(uuidString: (game["id"].stringValue)) ?? UUID(),
                steamID: game["steamID"].stringValue,
                igdbID: game["igdbID"].stringValue,
                gameFile: gameFile,
                launcher: game["launcher"].stringValue,
                metadata: game["metadata"].dictionaryObject as? [String: String] ?? ["":""],
                screenshots: game["screenshots"].arrayValue.map({ $0.stringValue }),
                icon: game["icon"].stringValue,
                name: game["name"].stringValue,
                platformName: platformString,
                status: Status(rawValue: game["status"].stringValue) ?? .none,
                recency: Recency(rawValue: game["recency"].stringValue) ?? .never,
                isHidden: game["isHidden"].boolValue,
                isFavorite: game["isFavorite"].boolValue
            ))
        }
    } else {
        // create empty games.json if it doesn't exist
        logger.write("[INFO]: Couldn't find games.json. Creating new one.")
        saveJSONData(to: "games", with: "{\"games\": }")
    }
    return games
}

func loadPlatformsFromJSON() -> [Platform] {
    let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/platforms.json")
    var platforms: [Platform] = []
    if let json = try? JSON(data: Data(contentsOf: url)) {
        let platformArray = json["platforms"].arrayValue
        for platform in platformArray {
            platforms.append(Platform(
                id: UUID(uuidString: (platform["id"].stringValue)) ?? UUID(),
                iconURL: platform["iconURL"].stringValue,
                name: platform["name"].stringValue,
                gameType: platform["gameType"].stringValue,
                gameDirectories: platform["gameDirectory"].string != nil ? [platform["gameDirectory"].stringValue] : platform["gameDirectories"].arrayValue.map({ $0.stringValue }),
                emulator: platform["emulator"].boolValue,
                emulatorExecutable: platform["emulatorExecutable"].stringValue,
                commandArgs: platform["commandArgs"].stringValue,
                commandTemplate: platform["commandTemplate"].stringValue,
                deletable: platform["deletable"].boolValue
            ))
        }
    } else {
        platforms = [
            Platform(iconURL: "https://api.iconify.design/ic:baseline-apple.svg", name: "Mac", gameType: "app", gameDirectories: ["/Applications"], commandTemplate: "open %@", deletable: false),
            Platform(iconURL: "https://api.iconify.design/ri:steam-fill.svg", name: "Steam", gameDirectories: [getApplicationSupportDirectory().appendingPathComponent("steam/steamapps").path], commandTemplate: "open steam://run/%@", deletable: false),
            Platform(iconURL: "https://api.iconify.design/mdi:gog.svg", name: "GOG", commandTemplate: "open %@"),
            Platform(iconURL: "https://api.iconify.design/grommet-icons:windows-legacy.svg", name: "PC"),
            Platform(iconURL: "https://api.iconify.design/ri:playstation-fill.svg", name: "Playstation", emulator: true),
            Platform(iconURL: "https://api.iconify.design/ri:xbox-fill.svg", name: "Xbox", emulator: true),
            Platform(iconURL: "https://api.iconify.design/cbi:nintendo-switch-logo.svg", name: "Nintendo", emulator: true),
            Platform(iconURL: "https://api.iconify.design/fluent:border-none-20-filled.svg", name: "Other", deletable: false)
        ]
        // create empty games.json if it doesn't exist
        logger.write("[INFO]: Couldn't find platforms.json. Creating new one.")
        saveJSONData(to: "platforms", with: convertPlatformsToJSONString(platforms))
    }
    return platforms
}

func convertGamesToJSONString(_ games: [Game]) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let gamesJSON = try JSONEncoder().encode(games)
        if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
            // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
            gamesJSONString = "{\"games\": \(gamesJSONString)}"
            return gamesJSONString
        } else {
            return ""
        }
    } catch {
        logger.write(error.localizedDescription)
        return ""
    }
}

func convertPlatformsToJSONString(_ platforms: [Platform]) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let platformsJSON = try JSONEncoder().encode(platforms)
        if var platformsJSONString = String(data: platformsJSON, encoding: .utf8) {
            // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
            platformsJSONString = "{\"platforms\": \(platformsJSONString)}"
            return platformsJSONString
        } else {
            return ""
        }
    } catch {
        logger.write(error.localizedDescription)
        return ""
    }
}

/// Writes the given data to a JSON file named "\(jsonName).json" in the "Phoenix"
/// directory under the application support directory. If it doesn't exist, creates it.
///
/// - Parameters:
///    - jsonName: The data to write to the JSON file.
///    - data: The data to write to the JSON file.
///
/// - Returns: Void.
///
/// - Throws: An error if there was a problem creating the directory or file, or
/// writing to the file.
func saveJSONData(to jsonName: String, with data: String) {
    let fileManager = FileManager.default
    let jsonFile = getApplicationSupportDirectory().appendingPathComponent(
        "Phoenix", isDirectory: true).appendingPathComponent("\(jsonName).json", conformingTo: .json)
    
    // Checks if ~/Library/Application Support/Phoenix directory exists
    checkAppSupportDir()

    // If .../Application Support/Phoenix/games.json file exists
    if fileManager.fileExists(atPath: jsonFile.path) {
        writeDataToJSON(named: jsonName, with: data)
    } else {
        createJSON(named: jsonName, with: data)
    }
}

func checkAppSupportDir() {
    let fileManager = FileManager.default
    let phoenixDirectory = getApplicationSupportDirectory().appendingPathComponent(
        "Phoenix", isDirectory: true)
    let cachedImagesDirectory = phoenixDirectory.appendingPathComponent(
        "cachedImages", conformingTo: .directory)
    if !fileManager.fileExists(atPath: phoenixDirectory.path) {
        do {
            try fileManager.createDirectory(
                atPath: phoenixDirectory.path, withIntermediateDirectories: true)
            try fileManager.createDirectory(
                atPath: cachedImagesDirectory.path, withIntermediateDirectories: true)
        } catch {
            logger.write("[ERROR]: Could not create directory Application Support/Phoenix")
            return
        }
    }
}

func createJSON(named jsonName: String, with data: String) {
    let fileManager = FileManager.default
    let jsonFile = getApplicationSupportDirectory().appendingPathComponent(
        "Phoenix", isDirectory: true)
        .appendingPathComponent("\(jsonName).json", conformingTo: .json)
    if fileManager.createFile(atPath: jsonFile.path, contents: Data(data.utf8)) {
        logger.write("[INFO]: '\(jsonName).json' created successfully.")
    } else {
        logger.write("[ERROR]: '\(jsonName).json' not created.")
    }
}

func writeDataToJSON(named jsonName: String, with data: String) {
    let jsonFile = getApplicationSupportDirectory().appendingPathComponent(
        "Phoenix", isDirectory: true).appendingPathComponent("\(jsonName).json", conformingTo: .json)
    do {
        try data.write(to: jsonFile, atomically: true, encoding: .utf8)
        logger.write("[INFO]: '\(jsonName).json' updated successfully.")
    } catch {
        logger.write("[ERROR]: Could not write data to '\(jsonName).json'")
    }
}
