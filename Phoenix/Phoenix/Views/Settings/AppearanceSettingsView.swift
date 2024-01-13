//
//  AppearanceSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Default(.listIconsHidden) var listIconsHidden
    @Default(.listIconSize) var listIconSize

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                // detail settings
                Defaults.Toggle(String(localized: "appearance_Accent"), key: .accentColorUI)
                Defaults.Toggle(String(localized: "appearance_Gradient"), key: .gradientUI)
                Defaults.Toggle(String(localized: "appearance_Star"), key: .showStarRating)
                Divider() // sidebar settings
                Defaults.Toggle(String(localized: "appearance_HideIcons"), key: .listIconsHidden)
                if !listIconsHidden {
                    Slider(
                        value: $listIconSize,
                        in: 20 ... 48,
                        step: 4
                    ) {
                        Text(LocalizedStringKey("appearance_IconSize"))
                    } minimumValueLabel: {
                        Text("20 px")
                    } maximumValueLabel: {
                        Text("48 px")
                    }
                    .frame(maxWidth: 225)
                }
                Defaults.Toggle(String(localized: "appearance_GameCount"), key: .showSortByNumber)
                Defaults.Toggle(String(localized: "appearance_ShowAdd"), key: .showSidebarAddGameButton)
                Divider() // toolbar settings
                Defaults.Toggle(String(localized: "appearance_CategoryAnimation"), key: .showAnimationOfSortByIcon)
                Defaults.Toggle(String(localized: "appearance_CategoryText"), key: .showPickerText)
            }
            .padding(20)
        }
    }
}
