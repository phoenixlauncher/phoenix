//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import AlertToast
import StarRatingViewSwiftUI
import SwiftUI
import QuickLook

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct GameDetailView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var supabaseViewModel: SupabaseViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var platformViewModel: PlatformViewModel

    @State var selectedGameName: String?

    @State var rating: Float = 0
    
    var game: Game? {
        gameViewModel.getGameFromID(id: gameViewModel.selectedGame) ?? nil
    }
    
    var currentPlatform: Platform? {
        platformViewModel.platforms.first(where: {game?.platformName == $0.name})
    }
    
    @State var headerFound = true
    @State var animate = false
    @State var selectedScreenshot: URL?

    @Default(.accentColorUI) var accentColorUI
    @Default(.showStarRating) var showStarRating
    @Default(.gradientHeader) var gradientHeader
    @Default(.showScreenshots) var showScreenshots
    @Default(.screenshotSize) var screenshotSize
    @Default(.fadeLeadingScreenshots) var fadeLeadingScreenshots

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                if let game = game {
                    // create header image
                    if let headerImage = game.metadata["header_img"] {
                        Image(nsImage: loadImageFromFile(filePath: headerImage.replacingOccurrences(of: "\\", with: ":")))
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width, height: getHeightForHeaderImage(geometry) + (gradientHeader ? 25 : 0)
                            )
                            .if(gradientHeader) { view in
                                view.mask(LinearGradient(gradient: Gradient(stops: [
                                    .init(color: Color.white, location: 0.3),
                                    .init(color: Color.clear, location: 0.97)
                            ]), startPoint: .top, endPoint: .bottom))
                            }
                            .if(!gradientHeader) { view in
                                view.clipped()
                            }
                            .blur(radius: getBlurRadiusForImage(geometry))
                            .offset(x: 0, y: getOffsetForHeaderImage(geometry))
                    }
                }
            }
            .task {
                checkHeader()
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
                                    .padding(.horizontal)
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
                                if let description = game?.metadata["description"] {
                                    TextCard(text: description)
                                } else {
                                    TextCard(text: String(localized: "detail_NoDesc"))
                                }
                                if showScreenshots {
                                    ScrollView([.horizontal]) {
                                        HStack {
                                            ForEach(game?.screenshots ?? [], id: \.self) { screenshot in
                                                if let screenshot = screenshot, let screenshotURL = URL(string: screenshot) {
                                                    AsyncImage(url: screenshotURL) { phase in
                                                        switch phase {
                                                        case .success(let image):
                                                            image.resizable()
                                                        default:
                                                            EmptyView()
                                                        }
                                                    }
                                                    .cornerRadius(7.5)
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: screenshotSize)
                                                    .onTapGesture(count: 2) {
                                                        selectedScreenshot = screenshotURL
                                                    }
                                                    .quickLookPreview($selectedScreenshot)
                                                }
                                            }
                                        }
                                    }
                                    .mask(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: fadeLeadingScreenshots ? Color.clear : Color.white, location: 0.0),
                                                .init(color: fadeLeadingScreenshots ? Color.white : Color.white, location: 0.15),
                                                .init(color: Color.white, location: 0.85),
                                                .init(color: Color.clear, location: 1.0)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(7.5)
                                    .frame(maxWidth: 1280)
                                    .task {
                                        checkScreenshots()
                                    }
                                }
                            }
                            .padding(.trailing, 7.5)
                            VStack {
                                SlotCard(content: {
                                    if let game = game {
                                        VStack(alignment: .leading, spacing: 7.5) {
                                            GameMetadata(field: String(localized: "detail_LP"), value: game.metadata["last_played"] ?? String(localized: "recency_Never"))
                                            GameMetadata(field: String(localized: "detail_Platform"), value: game.platformName)
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
            checkHeader()
            if showScreenshots { checkScreenshots() }
        }
    }

    private func checkHeader() {
        Task {
            print("header check starting ‼️")
            let fileManager = FileManager.default
            if let headerImage = game?.metadata["header_img"], let headerURL = URL(string: headerImage), fileManager.fileExists(atPath: headerURL.path) {
                print("header exists!!!!")
            } else {
                headerFound = false
                if let name = game?.name, let id = game?.id {
                    guard let igdbID = game?.igdbID, let igdbID = Int(igdbID) else {
                        await supabaseViewModel.fetchIgdbIDFromName(name: name) { igdbID in
                            updateGameIgdbID(id, igdbID: String(igdbID))
                        }
                        return
                    }
                    print("no header & valid id:")
                    print(igdbID)
                    print("asking supabsae now!!")
                    let headerData = try await supabaseViewModel.fetchAndSaveHeaderOf(gameID: id, igdbID: igdbID)
                    if let headerData = headerData {
                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }), let image = saveImageToFile(data: headerData, gameID: id, type: "header") {
                            print("found index")
                            gameViewModel.games[idx].metadata["header_img"] = image
                            gameViewModel.saveGames()
                            print("games saved")
                        }
                        headerFound = true
                    }
                }
            }
        }
    }

//    @MainActor
    private func updateGameScreenshots(_ id: UUID, screenshots: [String?]) {
        print("update func called")
        if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }) {
            print("found index")
            gameViewModel.games[idx].screenshots = screenshots
            gameViewModel.saveGames()
            print("games saved")
        }
    }
    
    private func checkScreenshots() {
        Task {
            print("task start")
            if game?.screenshots == [] || game?.screenshots == [""], let name = game?.name, let id = game?.id {
                if let igdbID = game?.igdbID, let igdbID = Int(igdbID) {
                    print("no scrreshots & valid id:")
                    print(igdbID)
                    await supabaseViewModel.fetchScreenshotsFromIgdbID(igdbID) { screenshots in
                        print("screenshots back")
                        updateGameScreenshots(id, screenshots: screenshots)
                    }
                } else {
                    print("invalid igdbID")
                    await supabaseViewModel.fetchIgdbIDFromName(name: name) { igdbID in
                        updateGameIgdbID(id, igdbID: String(igdbID))
                        Task {
                            await supabaseViewModel.fetchScreenshotsFromIgdbID(igdbID) { screenshots in
                                print("screenshots back")
                                updateGameScreenshots(id, screenshots: screenshots)
                            }
                        }
                    }
                }
            } else {
                print("screenshots exist")
            }
        }
    }
    
    @MainActor
    private func updateGameIgdbID(_ id: UUID, igdbID: String) {
        print("update func called")
        if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }) {
            print("found index")
            gameViewModel.games[idx].igdbID = igdbID
            gameViewModel.saveGames()
            print("games saved")
        }
    }

    func playGame(game: Game) {
        do {
            let currentDate = Date()
            // Update the last played date and write the updated information to the JSON file
            updateLastPlayedDate(currentDate: currentDate)
            if game.launcher != "" {
                try shell(game.launcher)
            } else {
                appViewModel.showFailureToast("\(String(localized: "toast_LaunchFailure")) \(gameViewModel.selectedGameName)")
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
