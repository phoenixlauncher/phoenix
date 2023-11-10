//
//  AppearanceSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Default(.listIconSize) var listIconSize
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                //detail settings
                Defaults.Toggle("Accent color UI", key: .accentColorUI)
                Defaults.Toggle("Gradient UI", key: .gradientUI)
                Divider() //sidebar settings
                Defaults.Toggle("Hide icons in sidebar", key: .listIconsHidden)
                if !Defaults[.listIconsHidden] {
                    Slider(
                        value: $listIconSize,
                        in: 20...48,
                        step: 4
                    ) {
                        Text("List icon size")
                    } minimumValueLabel: {
                        Text("20 px")
                    } maximumValueLabel: {
                        Text("48 px")
                    }
                    .frame(maxWidth: 225)
                }
                Defaults.Toggle("Show amount of games in sidebar", key: .showSortByNumber)
                Defaults.Toggle("Show add game button in sidebar", key: .showSidebarAddGameButton)
                Divider() //toolbar settings
                Defaults.Toggle("Show animation of category picker", key: .showAnimationOfSortByIcon)
                Defaults.Toggle("Show text in category picker", key: .showPickerText)
            }
            .padding(20)
        }
    }
}
