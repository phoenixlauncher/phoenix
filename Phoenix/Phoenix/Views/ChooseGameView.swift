//
//  ChooseGameView.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import SwiftUI
import IGDB_SWIFT_API
import Kingfisher

struct ChooseGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var games: [SupabaseGame]
    @State var selectedGame: SupabaseGame?
    var gameID: UUID
    
    var body: some View {
        VStack {
            List(selection: $selectedGame) {
                ForEach(games.sorted { $0.igdb_id < $1.igdb_id }, id: \.self) { game in
                    HStack(spacing: 20) {
                        if let cover = game.cover {
                            KFImage(URL(string: cover))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 150)
                                .cornerRadius(5)
                        }
                        VStack {
                            if let name = game.name {
                                Text(name) // UNCENTER ThIS TEXT
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                            }
                            if let description = game.description {
                                Text(description) //SHORTEN THIS TEXT TO 2 LINES
                                    .font(.caption)
                                    .lineLimit(3)
                            }
                        }
                    }
                }
            }
            Button(
                action: {
                    if let selectedGame = selectedGame {
                        chooseGame(selectedGame: selectedGame)
                        dismiss()
                    }
                },
                label: {
                    Text("Select Game")
                }
            )
        }
        .padding()
        .frame(minWidth: 720, minHeight: 250, idealHeight: 400)
        .onAppear {
            if games.count == 1 {
                chooseGame(selectedGame: $games.wrappedValue[0])
                dismiss()
            }
        }
    }
    
    func chooseGame(selectedGame: SupabaseGame) {
        print("converting to igdb")
        FetchSupabaseData().convertSupabaseGame(supabaseGame: selectedGame, gameID: gameID)
    }
}

