//
//  SettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI
import AlertToast

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label(String(localized: "prefs_General"), systemImage: "gear")
                }
            AppearanceSettingsView()
                .tabItem {
                    Label(String(localized: "prefs_Appearance"), systemImage: "paintpalette")
                }
            HiddenGamesSettingsView()
                .tabItem {
                    Label(String(localized: "prefs_Hidden"), systemImage: "eye.slash.fill")
                }
            PlatformsSettingsView()
                .tabItem {
                    Label(String(localized: "prefs_Platforms"), systemImage: "gamecontroller")
                }
        }
        .frame(idealWidth: 600)
        .toast(isPresenting: $appViewModel.showSettingsSuccessToast, tapToDismiss: true) {
            AlertToast(type: .complete(Color.green), title: appViewModel.successToastText)
        }
        .toast(isPresenting: $appViewModel.showSettingsFailureToast, tapToDismiss: true) {
            AlertToast(type: .error(Color.red), title: appViewModel.failureToastText)
        }
    }
}
