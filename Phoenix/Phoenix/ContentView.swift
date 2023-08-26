//
//  ContentView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

private let headerImageHeight: CGFloat = 500
private let collapsedImageHeight: CGFloat = 150

var games = loadGames().games.sorted()

struct ContentView: View {
    @Environment(\.openWindow) var openWindow
    @Binding var sortBy: PhoenixApp.SortBy
    @State var searchText: String = ""
    @State var selectedGame: String?
    @State var refresh: Bool = false
    @State private var isAddingGame: Bool = false

    // The stuff that is actually on screen
    var body: some View {
        NavigationSplitView {
            // The sidebar
            GameListView(sortBy: $sortBy, selectedGame: $selectedGame, refresh: $refresh, searchText: $searchText)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        // Add game button
                        Button(
                            action: {
                                self.isAddingGame.toggle()
                            },
                            label: {
                                Label("New Game", systemImage: "plus")
                            }
                        )
                        .sheet(
                            isPresented: $isAddingGame,
                            onDismiss: {
                                // Refresh game list
                                self.refresh.toggle()
                            },
                            content: {
                                AddGameView()
                            }
                        )
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Picker("Sort by", selection: $sortBy) {
                            ForEach(PhoenixApp.SortBy.allCases) { sortBy in
                                HStack(alignment: .center, spacing: 5) {
                                    Image(systemName: sortBy.symbol)
                                    Text(sortBy.displayName)
                                }
                            }
                        }
                        .pickerStyle(.automatic)
                    }
                }
        } detail: {
            // The detailed view of the selected game
            GameDetailView(selectedGame: $selectedGame, refresh: $refresh)

            // Refresh detail view
            Text(String(refresh))
                .hidden()
        }
        .searchable(text: $searchText, placement: .sidebar)
    }
}
