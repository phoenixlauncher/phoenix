//
//  ContentView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

private let headerImageHeight: CGFloat = 500
private let collapsedImageHeight: CGFloat = 150

var games = loadGamesFromJSON().games.sorted()

struct ContentView: View {
    @Environment(\.openWindow) var openWindow
    @State var selectedGame: String?
    @State var refresh: Bool = false
    @State private var addingGame: Bool = false

    // The stuff that is actually on screen
    var body: some View {
        NavigationSplitView {
            // The sidebar
            GameListView(selectedGame: $selectedGame, refresh: $refresh)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            addingGame.toggle()
                        }, label: {
                            Label("New Game", systemImage: "plus")
                        })
                        .sheet(isPresented: $addingGame, onDismiss: {
                            // Refresh game list
                            refresh.toggle()
                        }, content: {
                            AddGameView()
                        })
                    }
                }
        } detail: {
            // The detailed view of the selected game
            GameDetailView(selectedGame: $selectedGame, refresh: $refresh)
            Text(String(refresh))
                .hidden()
        }
    }
}
