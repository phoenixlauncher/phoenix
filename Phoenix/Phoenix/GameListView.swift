//
//  GameListView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//

import SwiftUI

struct GameListView: View {
  @Binding var selectedGame: String?
  @Binding var refresh: Bool

  var body: some View {
    List(selection: $selectedGame) {
      ForEach(Platform.allCases, id: \.self) { platform in
        let gamesForPlatform = games.filter { $0.platform == platform }
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
                Button("Delete game") {
                  if let idx = games.firstIndex(where: { $0.name == game.name }) {
                    games.remove(at: idx)
                    refresh.toggle()

                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted

                    do {
                      let gamesJSON = try JSONEncoder().encode(games)

                      if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                        // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                        gamesJSONString = "{\"games\": \(gamesJSONString)}"
                        writeGamesToJSON(data: gamesJSONString)
                      }
                    } catch {
                      print(error.localizedDescription)
                    }
                  }
                }
              }
            }
          }.scrollDisabled(true)
        }
      }
      Text(String(refresh))
        .hidden()
    }
    .onAppear {
      if selectedGame == nil {
        selectedGame = games[0].name
      }
    }
  }
}
