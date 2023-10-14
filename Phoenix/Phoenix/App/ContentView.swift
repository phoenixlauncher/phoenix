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
    @Binding var selectedGame: UUID?
    @State var refresh: Bool = false
    @State private var timer: Timer?
    @Binding var isAddingGame: Bool
    @Binding var isEditingGame: Bool
    @Binding var isPlayingGame: Bool
    @State var pickerText: Bool = true
    @State var showSuccessToast: Bool = false
    
    @State var animate: Bool = false

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
                                GameInputView(isNewGame: true, selectedGame: $selectedGame, showSuccessToast: $showSuccessToast)
                            }
                        )
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ZStack(alignment: .leading) {
                            Menu("\(pickerText ? sortBy.spaces : sortBy.spacedName)") {
                                ForEach(PhoenixApp.SortBy.allCases) { currentSortBy in
                                    Button("\(currentSortBy.displayName)",
                                        action: {
                                            sortBy = currentSortBy
                                        }
                                    )
                                }
                            }
                            .animation(.easeInOut)
                            if #available(macOS 14, *) {
                                Image(systemName: sortBy.symbol)
                                    .symbolRenderingMode(.palette)
                                    .symbolEffect(.bounce, value: animate)
                                    .contentTransition(.symbolEffect(.replace.byLayer.downUp))
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 15))
                                    .padding(.leading, 7)
                            } else {
                                Image(systemName: sortBy.symbol)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 15))
                                    .padding(.leading, 7)                            }
                            
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
                pickerText = true
            } else {
                pickerText = false
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if UserDefaults.standard.bool(forKey: "picker") {
                    pickerText = true
                } else {
                    pickerText = false
                }
                refresh.toggle()
                // This code will be executed every 1 second
            }
        }
        .onChange(of: sortBy) { _ in
            animate.toggle()
        }
        .searchable(text: $searchText, placement: .sidebar)
        .toast(isPresenting: $showSuccessToast, tapToDismiss: true) {
            AlertToast(type: .complete(Color.green), title: "Game created.")
        }
    }
}
