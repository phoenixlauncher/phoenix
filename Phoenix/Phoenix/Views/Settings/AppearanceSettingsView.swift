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
    
    @Default(.showScreenshots) var showScreenshots
    @Default(.screenshotSize) var screenshotSize

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                // detail settings
                Defaults.Toggle(String(localized: "appearance_Accent"), key: .accentColorUI)
                Defaults.Toggle(String(localized: "appearance_Gradient"), key: .gradientUI)
                Defaults.Toggle(String(localized: "appearance_Star"), key: .showStarRating)
                Defaults.Toggle(String(localized: "appearance_GradientHeader"), key: .gradientHeader)
                Defaults.Toggle(String(localized: "appearance_ShowScreenshots"), key: .showScreenshots)
                if showScreenshots {
                    Slider(
                        value: $screenshotSize,
                        in: 175 ... 250,
                        step: 15
                    ) {
                        Text(LocalizedStringKey("appearance_ScreenshotSize"))
                    } minimumValueLabel: {
                        Text("175 px")
                    } maximumValueLabel: {
                        Text("250 px")
                    }
                    .frame(maxWidth: 225)
                }
                Defaults.Toggle(String(localized: "appearance_FadeLeadingScreenshots"), key: .fadeLeadingScreenshots)
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
                VStack(alignment: .leading) {
                    Defaults.Toggle(String(localized: "appearance_CategoryAnimation"), key: .showAnimationOfSortByIcon)
                    Text(LocalizedStringKey("prefs_SonomaRequired"))
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                Defaults.Toggle(String(localized: "appearance_CategoryText"), key: .showPickerText)
            }
            .padding(20)
        }
    }
}
