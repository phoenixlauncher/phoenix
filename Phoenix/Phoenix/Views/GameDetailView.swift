//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import AlertToast
import StarRatingViewSwiftUI
import SwiftUI

struct GameDetailView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var supabaseViewModel: SupabaseViewModel
    @EnvironmentObject var appViewModel: AppViewModel

    @State var selectedGameName: String?

    @State var rating: Float = 0

    @Default(.accentColorUI) var accentColorUI
    @Default(.showStarRating) var showStarRating

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                let game = gameViewModel.getGameFromID(id: gameViewModel.selectedGame)
                if let game = game {
                    // create header image
                    if let headerImage = game.metadata["header_img"] {
                        Image(nsImage: loadImageFromFile(filePath: headerImage.replacingOccurrences(of: "\\", with: ":")))
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width, height: getHeightForHeaderImage(geometry)
                            )
                            .blur(radius: getBlurRadiusForImage(geometry))
                            .clipped()
                            .offset(x: 0, y: getOffsetForHeaderImage(geometry))
                    }
                }
            }
            .frame(height: 400)
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            // play button
                            LargeToggleButton(toggle: $appViewModel.isPlayingGame, symbol: "play.fill", text: String(localized: "detail_Play"), textColor: Color.white, bgColor: accentColorUI ? Color.accentColor : Color.green)
                            // settings button
                            SmallToggleButton(toggle: $appViewModel.isEditingGame, symbol: "pencil", textColor: accentColorUI ? Color.accentColor : Color.primary, bgColor: accentColorUI ? Color.accentColor.opacity(0.25) : Color.gray.opacity(0.25))
                            if showStarRating {
                                StarRatingView(rating: $rating, color: accentColorUI ? Color.accentColor : Color.orange)
                                    .frame(width: 300, height: 30)
                                    .padding()
                                    .onHover { _ in
                                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == gameViewModel.selectedGame }) {
                                            gameViewModel.games[idx].metadata["rating"] = String(rating)
                                        }
                                        gameViewModel.saveGames()
                                    }
                            }
                        } // hstack
                        .frame(alignment: .leading)
                        HStack(alignment: .top) {
                            // description
                            VStack(alignment: .leading) {
                                let game = gameViewModel.getGameFromID(id: gameViewModel.selectedGame)
                                if game?.metadata["description"] != "" {
                                    TextCard(text: game?.metadata["description"] ?? String(localized: "detail_NoGame"))
                                } else {
                                    TextCard(text: String(localized: "detail_NoDesc"))
                                }
                            }
                            .padding(.trailing, 7.5)

                            SlotCard(content: {
                                let game = gameViewModel.getGameFromID(id: gameViewModel.selectedGame)
                                if let game = game {
                                    VStack(alignment: .leading, spacing: 7.5) {
                                        GameMetadata(field: String(localized: "detail_LP"), value: game.metadata["last_played"] ?? String(localized: "recency_Never"))
                                        GameMetadata(field: String(localized: "detail_Platform"), value: game.platform.displayName)
                                        GameMetadata(field: String(localized: "detail_Status"), value: game.status.displayName)
                                        if !showStarRating {
                                            GameMetadata(field: String(localized: "detail_Rating"), value: game.metadata["rating"] ?? "")
                                        }
                                        GameMetadata(field: String(localized: "detail_Genres"), value: game.metadata["genre"] ?? "")
                                        GameMetadata(field: String(localized: "detail_Dev"), value: game.metadata["developer"] ?? "")
                                        GameMetadata(field: String(localized: "detail_Pub"), value: game.metadata["publisher"] ?? "")
                                        GameMetadata(field: String(localized: "detail_Release"), value: game.metadata["release_date"] ?? "")
                                    }
                                    .padding(.trailing, 10)
                                    .frame(minWidth: 150, alignment: .leading)
                                }
                            })
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.top, 10)
                    }
                    .padding(EdgeInsets(top: 10, leading: 17.5, bottom: 10, trailing: 17.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle(gameViewModel.selectedGameName)
        .onAppear {
            let game = gameViewModel.getGameFromID(id: gameViewModel.selectedGame)
            if let gameRating = game?.metadata["rating"] {
                rating = Float(gameRating) ?? 0
            }
        }
        .onChange(of: appViewModel.isPlayingGame) { _ in
            let game = gameViewModel.getGameFromID(id: gameViewModel.selectedGame)
            if let game = game {
                playGame(game: game)
            }
        }
        .onChange(of: gameViewModel.selectedGame) { _ in
            if let idx = gameViewModel.games.firstIndex(where: { $0.id == gameViewModel.selectedGame }) {
                Defaults[.selectedGame] = gameViewModel.selectedGame
                gameViewModel.selectedGameName = gameViewModel.games[idx].name
            }
            let game = gameViewModel.getGameFromID(id: gameViewModel.selectedGame)
            if let gameRating = game?.metadata["rating"] {
                rating = Float(gameRating) ?? 0
            }
        }
    }

    func playGame(game: Game) {
        do {
            let currentDate = Date()
            // Update the last played date and write the updated information to the JSON file
            updateLastPlayedDate(currentDate: currentDate)
            if game.launcher != "" {
                try shell(game)
            } else {
                appViewModel.showFailureToast("\(String(localized: "toast_Failure")) \(gameViewModel.selectedGameName)")
            }
        } catch {
            logger.write("\(error)") // handle or silence the error here
        }
    }

    func updateLastPlayedDate(currentDate: Date) {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()

        // Convert the current date to a string using the dateFormatter
        let dateString = dateFormatter.string(from: currentDate)

        // Update the value of "last_played" in the game's metadata
        if let idx = gameViewModel.games.firstIndex(where: { $0.id == gameViewModel.selectedGame }) {
            gameViewModel.games[idx].metadata["last_played"] = dateString
            gameViewModel.games[idx].recency = .day
            gameViewModel.saveGames()
        }
    }
}
