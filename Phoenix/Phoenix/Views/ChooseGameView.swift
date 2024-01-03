//
//  ChooseGameView.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import SwiftUI
import Kingfisher

struct ChooseGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var supabaseViewModel: SupabaseViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var games: [SupabaseGame]
    @State var supabaseGame: SupabaseGame?
    var gameID: UUID
    
    @Binding var done: Bool
    
    var body: some View {
        VStack {
            List(selection: $supabaseGame) {
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
                                Text(name)
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                            }
                            if let summary = game.summary {
                                Text(summary) //SHORTEN THIS TEXT TO 2 LINES
                                    .font(.caption)
                                    .lineLimit(3)
                            }
                        }
                    }
                }
            }
            Button(
                action: {
                    if let supabaseGame = supabaseGame {
                        chooseGame(supabaseGame)
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
                chooseGame($games.wrappedValue[0])
                dismiss()
            }
        }
    }
    
    func chooseGame(_ supabaseGame: SupabaseGame) {
        done = true
        supabaseViewModel.convertSupabaseGame(supabaseGame: supabaseGame, game: Game(id: gameID)) { result in
            gameViewModel.addGame(result)
        }
    }
}

