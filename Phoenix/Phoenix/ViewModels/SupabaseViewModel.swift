//
//  SupabaseViewModel.swift
//  Phoenix
//
//  Created by jxhug on 12/29/23.
//

import Foundation
import Supabase

@MainActor
class SupabaseViewModel: ObservableObject {
    
    let supabase = SupabaseClient(supabaseURL: URL(string: "https://xcvgscmerrimxzykhwwj.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdmdzY21lcnJpbXh6eWtod3dqIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY1NzI0MzQsImV4cCI6MjAxMjE0ODQzNH0.HQmy-ngtIcJxQmyopQ9xaRYlVXlCVwDNYwQ1WOxmMus")
        
    func fetchGamesFromName(name: String) async -> [SupabaseGame] {
        // Create a select request from supabase and save it to games
        if name != "" {
            do {
                let games: [SupabaseGame] = try await supabase.database
                    .from("igdb_games")
                    .select()
                    .ilike("name", value: "%\(name)%")
                    .execute()
                    .value
                return games
            } catch {
                // Handle the error
                logger.write("An error occurred: \(error)")
            }
        }
        return []
    }
    
    func fetchIgbdIDsFromName(name: String) async -> [SupabaseGame] {
        // Create a select request from supabase and save it to games
        if name != "" {
            do {
                let igdbIDs: [SupabaseGame] = try await supabase.database
                    .from("igdb_games")
                    .select("igdb_id")
                    .eq("name", value: name)
                    .execute()
                    .value
                return igdbIDs
            } catch {
                // Handle the error
                logger.write("An error occurred: \(error)")
            }
        }
        return []
    }
    
    func fetchIgbdIDsFromPatternName(name: String) async -> [SupabaseGame] {
        // Create a select request from supabase and save it to games
        if name != "" {
            do {
                let igdbIDs: [SupabaseGame] = try await supabase.database
                    .from("igdb_games")
                    .select("igdb_id, name")
                    .ilike("name", value: "%\(name)%")
                    .execute()
                    .value
                return igdbIDs
            } catch {
                // Handle the error
                logger.write("An error occurred: \(error)")
            }
        }
        return []
    }
    
    func fetchIgbdIDsFromPatternNameWithSpaces(name: String) async -> [SupabaseGame] {
        // Create a select request from supabase and save it to games
        if name != "" {
            do {
                let igdbIDs: [SupabaseGame] = try await supabase.database
                    .from("igdb_games")
                    .select("igdb_id, name")
                    .ilike("name", value: "%\(name.replacingOccurrences(of: " ", with: "%"))%")
                    .execute()
                    .value
                return igdbIDs
            } catch {
                // Handle the error
                logger.write("An error occurred: \(error)")
            }
        }
        return []
    }
    
    func fetchGameFromIgdbID(_ igdbID: Int) async -> SupabaseGame? {
        // Create a select request from supabase and save it to games
        do {
            let games: [SupabaseGame] = try await supabase.database
                .from("igdb_games")
                .select()
                .eq("igdb_id", value: igdbID)
                .execute()
                .value
            return games.first
        } catch {
            // Handle the error
            logger.write("An error occurred: \(error)")
        }
        return nil
    }
    
    func fetchGameFromSteamID(steamID: String) async -> SupabaseGame? {
        // Create a select request from supabase and save it to games
        if steamID != "" {
            do {
                let games: [SupabaseGame] = try await supabase.database
                    .from("igdb_games")
                    .select()
                    .eq("steam_id", value: steamID)
                    .execute()
                    .value
                return games.first
            } catch {
                // Handle the error
                logger.write("An error occurred: \(error)")
            }
        }
        return nil
    }
    
    func fetchIgdbIDFromName(name: String, completion: @escaping (Int) -> Void) async {
        // Create a select request from supabase and save it to games
        if name != "" {
            do {
                let response: [SupabaseIgdbID] = try await supabase.database
                    .from("igdb_games")
                    .select("igdb_id")
                    .ilike("name", value: name)
                    .execute()
                    .value
                if response.count > 0 {
                    let igdbID = response[0].igdb_id
                    completion(igdbID)
                }
            } catch {
                // Handle the error
                logger.write("An error occurred: \(error)")
            }
        }
    }
    
    func convertSupabaseGame(supabaseGame: SupabaseGame, game: Game) async -> (Game, Data?) {
        var game = game
        var headerData: Data?
        
        game.igdbID = "\(supabaseGame.igdb_id)"
        
        if let storyline = supabaseGame.storyline, storyline.count < 1500, storyline != "" {
            game.metadata["description"] = storyline
        } else {
            game.metadata["description"] = supabaseGame.summary ?? ""
        }
        if let screenshots = supabaseGame.screenshots {
            game.screenshots = screenshots
        }

        game.metadata["genre"] = supabaseGame.genre?.replacingOccurrences(of: ", ", with: "\n")

        game.metadata["developer"] = supabaseGame.developer?.replacingOccurrences(of: ", ", with: "\n")
        game.metadata["publisher"] = supabaseGame.publisher?.replacingOccurrences(of: ", ", with: "\n")

        if let release_date = supabaseGame.release_date {
            // Convert Unix timestamp to Date
            let date = Date(timeIntervalSince1970: TimeInterval(release_date))
    
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
    
            game.metadata["release_date"] = dateFormatter.string(from: date)
        }
        
        if let steam_id = supabaseGame.steam_id {
            game.steamID = steam_id
            if (game.launcher == "" || game.launcher.contains("%@")) && game.platformName == "Steam" {
                game.launcher = "open steam://run/\(steam_id)"
            }
        }

        // Create a dispatch group

        if let imageURL = supabaseGame.header_img, let url = URL(string: imageURL) {
            do {
                headerData = try await URLSession.shared.data(from: url).0
            }
            catch {
                logger.write("header fetch error: \(error.localizedDescription)")
            }
        }
        
        return (game, headerData)
    }
    
    func fetchAndSaveHeaderOf(gameID: UUID, igdbID: Int) async throws -> Data? {
        // Create a select request from supabase and save it to games
        let dispatchGroup = DispatchGroup()
        do {
            let response: [SupabaseHeader] = try await supabase.database
                .from("igdb_games")
                .select("header_img")
                .eq("igdb_id", value: igdbID)
                .execute()
                .value
            if let header = response[0].header_img, let url = URL(string: header) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    return data
                } catch {
                    throw error
                }
            } else {
                return nil
            }
        } catch {
            // Handle the error
            throw error
        }
    }
    
    func fetchScreenshotsFromIgdbID(_ id: Int, completion: @escaping ([String?]) -> Void) async {
        // Create a select request from supabase and save it to games
        do {
            let response: [SupabaseScreenshots] = try await supabase.database
                .from("igdb_games")
                .select("screenshots")
                .eq("igdb_id", value: id)
                .execute()
                .value
            if let screenshots = response[0].screenshots {
                print("sending em back")
                print(response)
                completion(screenshots)
            }
        } catch {
            // Handle the error
            logger.write("An error occurred: \(error)")
        }
    }
}
