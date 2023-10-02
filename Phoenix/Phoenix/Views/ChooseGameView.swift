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
    
    @Binding var games: [Proto_Game]
    @State var selectedGame: Proto_Game?
    var nameInput: String
    
    var body: some View {
        VStack {
            List(selection: $selectedGame) {
                ForEach(games.sorted { $0.id < $1.id }, id: \.self) { game in
                    HStack(spacing: 20) {
                        KFImage(URL(string: imageBuilder(imageID: game.cover.imageID, size: .COVER_BIG, imageType: .JPEG)))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .cornerRadius(5)
                        VStack {
                            Text(game.name) // UNCENTER ThIS TEXT
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                            Text(game.summary) //SHORTEN THIS TEXT TO 2 LINES
                                .font(.caption)
                                .lineLimit(3)
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
    
    func chooseGame(selectedGame: Proto_Game) {
        print("converting to igdb")
        FetchGameData().convertIGDBGame(igdbGame: selectedGame, nameInput: nameInput)
    }
}

