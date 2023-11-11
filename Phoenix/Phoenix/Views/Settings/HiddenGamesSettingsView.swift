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
    @State private var timer: Timer?
    
    var body: some View {
        Form {
            VStack {
                List(selection: $selectedGame) {
                    let hiddenGames = games.filter { $0.isHidden == true}
                    if !hiddenGames.isEmpty {
                        ForEach(hiddenGames, id: \.id) { game in
                            HStack {
                                HStack {
                                    Image(nsImage: loadImageFromFile(filePath: game.icon))
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                    Text(game.name)
                                    Text(String(refresh))
                                        .hidden()
                                }
                                Spacer()
                                Button(action: {
                                    if let idx = games.firstIndex(where: { $0.id == game.id }) {
                                        games[idx].isHidden = false
                                    }
                                    self.refresh.toggle()
                                    saveGames()
                                }) {
                                    Text("Show game")
                                }
                                .accessibility(identifier: "Show Game")
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
    }
}
