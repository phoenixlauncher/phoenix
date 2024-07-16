//
//  HiddenGamesSettingsView.swift
//  Phoenix
//
//  Created by james hughes on 6/18/23.
//

import SwiftUI

struct HiddenGamesSettingsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel

    @State var iconsHidden: Bool = Defaults[.listIconsHidden]
    @State var iconSize: Double = Defaults[.listIconSize]

    var body: some View {
        Form {
            VStack {
                List() {
                    let hiddenGames = gameViewModel.games.filter { $0.isHidden == true }
                    if !hiddenGames.isEmpty {
                        ForEach(hiddenGames, id: \.id) { game in
                            HStack {
                                HStack {
                                    if !iconsHidden && game.icon != "" {
                                        Image(nsImage: loadImageFromFile(filePath: game.icon))
                                            .resizable()
                                            .frame(width: iconSize, height: iconSize)
                                    }
                                    Text(game.name)
                                }
                                Spacer()
                                HStack {
                                    Button(action: {
                                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                            gameViewModel.games[idx].isHidden = false
                                        }
                                        gameViewModel.saveGames()
                                    }) {
                                        Text(LocalizedStringKey("hidden_ShowGame"))
                                    }
                                    .accessibility(identifier: "Show Game")
                                    Button(action: {
                                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                            gameViewModel.games.remove(at: idx)
                                        }
                                        gameViewModel.saveGames()
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                    .accessibility(identifier: "Delete Game")
                                }
                            }
                        }.scrollDisabled(true)
                    } else {
                        Text(LocalizedStringKey("hidden_NoGames"))
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .onChange(of: Defaults[.listIconSize]) { value in
            iconSize = value
        }
    }
}
