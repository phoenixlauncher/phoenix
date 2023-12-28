//
//  FetchSupabaseData.swift
//  Phoenix
//
//  Created by James Hughes on 9/2/23.
//

import Foundation
import Supabase

struct SupabaseGame: Decodable, Hashable {
    var igdb_id: Int
    var steam_id: Int?
    var release_date: Int?
    var developer: String?
    var header_img: String?
    var cover: String?
    var storyline: String?
    var summary: String?
    var genre: String?
    var publisher: String?
    var icon: String?
    var name: String?
}

struct FetchSupabaseData {
    
    let supabase = SupabaseClient(supabaseURL: URL(string: "https://xcvgscmerrimxzykhwwj.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdmdzY21lcnJpbXh6eWtod3dqIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY1NzI0MzQsImV4cCI6MjAxMjE0ODQzNH0.HQmy-ngtIcJxQmyopQ9xaRYlVXlCVwDNYwQ1WOxmMus")
    
    func fetchGamesFromName(name: String, completion: @escaping ([SupabaseGame]) -> Void) async {
        // Create a select request from supabase and save it to fetchedGames
        if name != "" {
            do {
                let fetchedGames: [SupabaseGame] = try await supabase.database
                    .from("igdb_games")
                    .select()
                    .ilike("name", value: "%\(name)%")
                    .execute()
                    .value
                
                completion(fetchedGames)
            } catch {
                // Handle the error
                print("An error occurred: \(error)")
            }
        }
    }
    
    func convertSupabaseGame(supabaseGame: SupabaseGame, game: Game, completion: @escaping (Game) -> Void) {
        var fetchedGame: Game
        fetchedGame = .init(
            id: game.id,
            steamID: game.steamID,
            launcher: game.launcher,
            metadata: [
                "rating": game.metadata["rating"] ?? "",
                "release_date": game.metadata["release_date"] ?? "",
                "last_played": game.metadata["last_played"] ?? "",
                "developer": game.metadata["developer"] ?? "",
                "header_img": game.metadata["header_img"] ?? "",
                "cover": game.metadata["cover"] ?? "",
                "description": game.metadata["description"] ?? "",
                "genre": game.metadata["genre"] ?? "",
                "publisher": game.metadata["publisher"] ?? "",
            ],
            icon: game.icon,
            name: game.name,
            platform: game.platform,
            status: game.status,
            recency: game.recency,
            isFavorite: game.isFavorite
        )
        
        fetchedGame.igdbID = String(supabaseGame.igdb_id)
        
        if let storyline = supabaseGame.storyline, storyline.count < 1500, storyline != "" {
            fetchedGame.metadata["description"] = storyline
        } else {
            fetchedGame.metadata["description"] = supabaseGame.summary ?? ""
        }

        fetchedGame.metadata["genre"] = supabaseGame.genre?.replacingOccurrences(of: ", ", with: "\n")

        fetchedGame.metadata["developer"] = supabaseGame.developer?.replacingOccurrences(of: ", ", with: "\n")
        fetchedGame.metadata["publisher"] = supabaseGame.publisher?.replacingOccurrences(of: ", ", with: "\n")

        if let release_date = supabaseGame.release_date {
            // Convert Unix timestamp to Date
            let date = Date(timeIntervalSince1970: TimeInterval(release_date))
    
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
    
            fetchedGame.metadata["release_date"] = dateFormatter.string(from: date)
        }
        
        if let steam_id = supabaseGame.steam_id {
            fetchedGame.steamID = String(steam_id)
            if (fetchedGame.launcher == "" || fetchedGame.launcher.contains("%@")) && fetchedGame.platform == .steam {
                fetchedGame.launcher = "open steam://run/\(steam_id)"
            }   
        }

        if let imageURL = supabaseGame.header_img {
            if let url = URL(string: imageURL) {
                URLSession.shared.dataTask(with: url) { headerData, response, error in
                    if let headerData = headerData {
                        saveImageToFile(data: headerData, gameID: fetchedGame.id, type: "header") { headerImage in
                            fetchedGame.metadata["header_img"] = headerImage
                            saveFetchedGame(gameID: fetchedGame.id, fetchedGame: fetchedGame)
                        }
                    }
                }.resume()
            }
        }
        
        completion(fetchedGame)
    }
    
    func saveFetchedGame(gameID: UUID, fetchedGame: Game) {
        if let idx = games.firstIndex(where: { $0.id == gameID }) {
            games[idx] = fetchedGame
        }
        saveGames()
    }
}
