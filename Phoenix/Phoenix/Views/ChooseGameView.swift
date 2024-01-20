//
//  ChooseGameView.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import SwiftUI

struct ChooseGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var supabaseViewModel: SupabaseViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var supabaseGames: [SupabaseGame]
    @State var supabaseGame: SupabaseGame?
    var game: Game
    
    @Binding var done: Bool
    
    var body: some View {
        VStack {
            List(selection: $supabaseGame) {
                ForEach(supabaseGames.sorted { $0.igdb_id < $1.igdb_id }, id: \.self) { game in
                    HStack(spacing: 20) {
                        if let cover = game.cover {
                            AsyncImage(url: URL(string: cover)) { image in
                                image.image?.resizable()
                            }
                            .scaledToFit()
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
                    Text(LocalizedStringKey("editGame_SelectGame"))
                }
            )
        }
        .padding()
        .frame(minWidth: 720, minHeight: 250, idealHeight: 400)
        .onAppear {
            if supabaseGames .count == 1 {
                chooseGame($supabaseGames.wrappedValue[0])
                dismiss()
            }
        }
    }
    
    func chooseGame(_ supabaseGame: SupabaseGame) {
        done = true
        supabaseViewModel.convertSupabaseGame(supabaseGame: supabaseGame, game: game) { result in
            gameViewModel.addGame(result)
            gameViewModel.selectedGame = result.id
        }
    }
}

