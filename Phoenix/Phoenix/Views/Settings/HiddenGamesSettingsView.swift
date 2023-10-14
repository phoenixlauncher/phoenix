//
//  HiddenGamesSettingsView.swift
//  Phoenix
//
//  Created by james hughes on 6/18/23.
//

import SwiftUI
struct HiddenGamesSettingsView: View {
    
    @State var selectedGame: String?
    @State var refresh: Bool = false
    
    @State var noGamesTextDisplayed: Bool = false
    
    var body: some View {
        List(selection: $selectedGame) {
            ForEach(Platform.allCases, id: \.self) { platform in
                let gamesForPlatform = games.filter { $0.platform == platform && $0.is_deleted == true}
                if !gamesForPlatform.isEmpty {
                    Section(header: Text(platform.displayName)) {
                        ForEach(gamesForPlatform, id: \.name) { game in
                            HStack {
                                Image(nsImage: loadImageFromFile(filePath: game.icon))
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text(game.name)
                            }
                            .contextMenu {
                                Button(action: {
                                    restoreGame(game, refresh: $refresh)
                                }) {
                                    Text("Restore game")
                                }
                                .accessibility(identifier: "Restore Game")
                            }
                        }.scrollDisabled(true)
                    }
                }
            }
            Text(String(refresh))
                .hidden()
        }
    }
    
    func restoreGame(_ game: Game, refresh: Binding<Bool>) {
        if let idx = games.firstIndex(where: { $0.id == game.id }) {
            games[idx].is_deleted = false
            // REFRESH GAME LIST VIEW HERE
            logger.write("called function from settings view")
            refresh.wrappedValue.toggle()
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            do {
                let gamesJSON = try encoder.encode(games)

                if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                    // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                    gamesJSONString = "{\"games\": \(gamesJSONString)}"
                    writeGamesToJSON(data: gamesJSONString)
                }
            } catch {
                logger.write(error.localizedDescription)
            }
        }
    }
}
