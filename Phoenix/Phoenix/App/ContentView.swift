//
//  ContentView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI
import AlertToast

private let headerImageHeight: CGFloat = 500
private let collapsedImageHeight: CGFloat = 150

var games = loadGames().games.sorted()

struct ContentView: View {
    @Environment(\.openWindow) var openWindow
    @Binding var sortBy: PhoenixApp.SortBy
    @State var searchText: String = ""
    @Binding var selectedGame: String?
    @State var refresh: Bool = false
    @State private var timer: Timer?
    @Binding var isAddingGame: Bool
    @Binding var isEditingGame: Bool
    @Binding var isPlayingGame: Bool
    @State var picker: Bool = true
    @State var showSuccessToast: Bool = false

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
                                GameInputView(isNewGame: true, gameName: "", showSuccessToast: $showSuccessToast)
                            }
                        )
                    }
                    if picker {
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
                }
        } detail: {
            // The detailed view of the selected game
            GameDetailView(selectedGame: $selectedGame, refresh: $refresh, editingGame: $isEditingGame, playingGame: $isPlayingGame)

            // Refresh detail view
            Text(String(refresh))
                .hidden()
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "picker") {
                picker = true
            } else {
                picker = false
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if UserDefaults.standard.bool(forKey: "picker") {
                    picker = true
                } else {
                    picker = false
                }
                refresh.toggle()
                // This code will be executed every 1 second
            }
        }
        .searchable(text: $searchText, placement: .sidebar)
        .toast(isPresenting: $showSuccessToast, tapToDismiss: true) {
            AlertToast(type: .complete(Color.green), title: "Game created.")
        }
    }
}
