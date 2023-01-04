//
//  JsonUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

/**
 Returns the URL for the application support directory for the current user.
 
 - Returns: The URL for the application support directory.
 */
func getApplicationSupportDirectory() -> URL {
    // find all possible Application Support directories for this user
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    
    // just send back the first one, which ought to be the only one
    return paths[0]
}

///  Parses the appmanifest_<appid>.acf file and returns a dictionary of the key-value pairs.
///
///    - Parameters:
///      - data: The data from the appmanifest_<appid>.acf file.
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

///  Detects Steam games from application support directory
///  using the appmanifest_<appid>.acf files and writes them to the games.json file.
///
///    - Parameters: None.
///
///    - Returns: Void.
///
///    - Throws: An error if there was a problem writing to the file.
func detectSteamGamesAndWriteToJSON() {
  let fileManager = FileManager.default

  /// Get ~/Library/Application Support/Steam/steamapps
  /// Or when App Sandbox is enabled ~/Library/Containers/com.Shock9616.Phoenix/Data/Library/Application Support/Steam/steamapps
  /// Currently the app is not sandboxed, so the getApplicationSupportDirectory function will return the first option.

  let applicationSupportDirectory = getApplicationSupportDirectory()
  let steamAppsDirectory = applicationSupportDirectory.appendingPathComponent("Steam/steamapps")

  // Load the current list of games from the JSON file to prevent overwriting
  let currentGamesList = loadGamesFromJSON()

  // Create a set of the current game names to prevent duplicates
  var gameNames = Set(currentGamesList.games.map { $0.name })

  // Find the appmanifest_<appid>.acf files and parse data from them
  do {
    let steamAppsFiles = try fileManager.contentsOfDirectory(
      at: steamAppsDirectory, includingPropertiesForKeys: nil)
    var games = currentGamesList.games
    for steamAppsFile in steamAppsFiles {
      let fileName = steamAppsFile.lastPathComponent
      if fileName.hasSuffix(".acf") {
        let manifestFilePath = steamAppsFile
        let manifestFileData = try Data(contentsOf: manifestFilePath)
        let manifestDictionary = parseACFFile(data: manifestFileData)
        let name = manifestDictionary["name"]
        let appID = manifestDictionary["appid"]
        let game = Game(
          appID: appID ?? "Unknown",
          launcher: "open steam://run/\(appID ?? "Unknown")",
          metadata: [
            "rating": "",
            "release_date": "",
            "time_played": "",
            "last_played": "",
            "developer": "",
            "header_img": "",
            "description": "",
            "genre": "",
            "publisher": "",
          ],
          icon: "PlaceholderIcon",
          name: name ?? "Unknown",
          platform: Platform.STEAM
        )
        // Check if the game is already in the list
        if !gameNames.contains(game.name) {
          gameNames.insert(game.name)
          games.append(game)
        }
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
    print("Error writing steam games.")
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
  if FileManager.default.fileExists(
    atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix", isDirectory: true)
      .path)
  {
    // If .../Application Support/Phoenix/games.json file exists
    if FileManager.default.fileExists(
      atPath: getApplicationSupportDirectory().appendingPathComponent(
        "Phoenix/games.json", conformingTo: .json
      ).path)
    {
      let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
      do {
        try data.write(to: url, atomically: true, encoding: .utf8)
      } catch {
        print("Could not write data to 'games.json'")
      }
      // If .../Application Support/Phoenix/games.json file DOESN'T exist
    } else {
      if FileManager.default.createFile(
        atPath: getApplicationSupportDirectory().appendingPathComponent(
          "Phoenix/games.json", conformingTo: .json
        ).path, contents: Data(data.utf8))
      {
        print("'games.json' created successfully.")
      } else {
        print("'games.json' not created.")
      }
    }
    // If .../Application Support/Phoenix/cachedImages DOESN'T exist
    if FileManager.default.fileExists(
      atPath: getApplicationSupportDirectory().appendingPathComponent(
        "Phoenix/cachedImages", isDirectory: true
      ).path)
    {
      do {
        try FileManager.default.createDirectory(
          atPath: getApplicationSupportDirectory().appendingPathComponent(
            "Phoenix", conformingTo: .directory
          ).path, withIntermediateDirectories: true)
      } catch {
        print("Could not create directory")
      }
    }
    // If .../Application Support/Phoenix directory DOESN'T exist
  } else {
    do {
      try FileManager.default.createDirectory(
        atPath: getApplicationSupportDirectory().appendingPathComponent(
          "Phoenix", conformingTo: .directory
        ).path, withIntermediateDirectories: true)
      try FileManager.default.createDirectory(
        atPath: getApplicationSupportDirectory().appendingPathComponent(
          "Phoenix/cachedImages", conformingTo: .directory
        ).path, withIntermediateDirectories: true)

      if FileManager.default.createFile(
        atPath: getApplicationSupportDirectory().appendingPathComponent(
          "Phoenix/games.json", conformingTo: .json
        ).path, contents: Data(data.utf8))
      {
        print("'games.json' created successfully.")
      } else {
        print("'File' not created.")
      }
    } catch {
      print("Could not create directory")
    }
  }
}
