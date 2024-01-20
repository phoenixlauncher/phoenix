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

struct ContentView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @StateObject var supabaseViewModel = SupabaseViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    @Environment(\.openWindow) var openWindow
    @Binding var sortBy: PhoenixApp.SortBy
    @State var searchText: String = ""
    
    @Default(.showPickerText) var showPickerText
    @Default(.showSidebarAddGameButton) var showSidebarAddGameButton
    
    @State var animate: Bool = false

    // The stuff that is actually on screen
    var body: some View {
        NavigationSplitView {
            // The sidebar
            GameListView(sortBy: $sortBy, searchText: $searchText)
                .toolbar {
                    if !showSidebarAddGameButton {
                        ToolbarItem(placement: .primaryAction) {
                            // Add game button
                            Button(
                                action: {
                                    appViewModel.isAddingGame.toggle()
                                },
                                label: {
                                    Label(String(localized: "file_AddGame"), systemImage: "plus")
                                }
                            )
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ZStack(alignment: .leading) {
                            if #available(macOS 14, *), Defaults[.showAnimationOfSortByIcon] {
                                Menu("\(showPickerText ? sortBy.spaces : sortBy.spacedName)") {
                                    Text("\(String(localized: "category_SortBy")):")
                                    ForEach(PhoenixApp.SortBy.allCases) { currentSortBy in
                                        Button("\(currentSortBy.displayName)",
                                            action: {
                                                sortBy = currentSortBy
                                            }
                                        )
                                    }
                                }
                                .animation(.easeInOut)
                                Image(systemName: sortBy.symbol)
                                    .symbolRenderingMode(.palette)
                                    .symbolEffect(.bounce, value: animate)
                                    .contentTransition(.symbolEffect(.replace.byLayer.downUp))
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 15))
                                    .padding(.leading, 7)
                            } else {
                                Menu("\(showPickerText ? sortBy.spaces : sortBy.spacedName)") {
                                    Text("\(String(localized: "category_SortBy")):")
                                    ForEach(PhoenixApp.SortBy.allCases) { currentSortBy in
                                        Button("\(currentSortBy.displayName)",
                                            action: {
                                                sortBy = currentSortBy
                                            }
                                        )
                                    }
                                }
                                Image(systemName: sortBy.symbol)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 15))
                                    .padding(.leading, 7)
                            }
                        }
                    }
                }
        } detail: {
            if gameViewModel.games.count > 0 {
                // The detailed view of the selected game
                GameDetailView()
            } else {
                OnboardingDetailView()
            }
        }
        .sheet(isPresented: $appViewModel.isAddingGame) {
            GameInputView(isNewGame: true)
        }
        .sheet(isPresented: $appViewModel.isEditingGame) {
            GameInputView(isNewGame: false)
        }
        .environmentObject(supabaseViewModel)
        .environmentObject(appViewModel)
        .onChange(of: sortBy) { _ in
            animate.toggle()
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: String(localized: "gameList_Search"))
        .toast(isPresenting: $appViewModel.showSuccessToast, tapToDismiss: true) {
            AlertToast(type: .complete(Color.green), title: appViewModel.successToastText)
        }
        .toast(isPresenting: $appViewModel.showFailureToast, tapToDismiss: true) {
            AlertToast(type: .error(Color.red), title: appViewModel.failureToastText)
        }
    }
}
