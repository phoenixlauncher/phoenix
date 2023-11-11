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
                    Label("General", systemImage: "gear")
                }
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }
            HiddenGamesSettingsView()
                .tabItem {
                    Label("Hidden Games", systemImage: "eye.slash.fill")
                }
        }
        .frame(width: 500, height: 300)
    }
}
