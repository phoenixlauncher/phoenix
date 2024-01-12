//
//  SettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct SettingsView: View {
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
        }
        .frame(idealWidth: 400)
    }
}
