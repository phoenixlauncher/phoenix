//
//  SupabaseViewModel.swift
//  Phoenix
//
//  Created by jxhug on 12/29/23.
//

import Foundation
import Supabase

final class SupabaseViewModel: ObservableObject {
    
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

        // Create a dispatch group
        let dispatchGroup = DispatchGroup()

        if let imageURL = supabaseGame.header_img, let url = URL(string: imageURL) {
            // Enter the dispatch group before starting the image fetch
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { headerData, response, error in
                defer {
                    // Leave the dispatch group when the image fetch is done, regardless of success or failure
                    dispatchGroup.leave()
                }
                if let headerData = headerData {
                    saveImageToFile(data: headerData, gameID: fetchedGame.id, type: "header") { headerImage in
                        fetchedGame.metadata["header_img"] = headerImage
                    }
                }
                // Handle errors if needed
            }.resume()
        }
        // When all tasks in the dispatch group are done
        dispatchGroup.notify(queue: .main) {
            completion(fetchedGame)
        }
    }

}
