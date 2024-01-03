//
//  HiddenGamesSettingsView.swift
//  Phoenix
//
//  Created by james hughes on 6/18/23.
//

import SwiftUI

struct HiddenGamesSettingsView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    
    @State var selectedGame: String?
    @State var refresh: Bool = false
    @State private var timer: Timer?
    
    @State var iconsHidden: Bool = Defaults[.listIconsHidden]
    @State var iconSize: Double = Defaults[.listIconSize]
    
    var body: some View {
        Form {
            VStack {
                List(selection: $selectedGame) {
                    let hiddenGames = gameViewModel.games.filter { $0.isHidden == true}
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
                                    Text(String(refresh))
                                        .hidden()
                                }
                                Spacer()
                                HStack {
                                    Button(action: {
                                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                            gameViewModel.games[idx].isHidden = false
                                        }
                                        self.refresh.toggle()
                                        gameViewModel.saveGames()
                                    }) {
                                        Text("Show game")
                                    }
                                    .accessibility(identifier: "Show Game")
                                    Button(action: {
                                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                            gameViewModel.games.remove(at: idx)
                                        }
                                        gameViewModel.saveGames()
                                        self.refresh.toggle()
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                    .accessibility(identifier: "Delete Game")

                                }
                            }
                        }.scrollDisabled(true)
                    } else {
                        Text("No hidden games found.")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .onAppear {
            self.refresh.toggle()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.refresh.toggle()
                // This code will be executed every 1 second
            }
        }
        .onChange(of: Defaults[.listIconSize]) { value in
            iconSize = value
        }
    }
}
