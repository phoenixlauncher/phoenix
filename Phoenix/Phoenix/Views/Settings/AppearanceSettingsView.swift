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
            VStack(alignment: .leading, spacing: 20) {
                Defaults.Toggle("Adaptive Color UI", key: .accentColorUI)
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
                Defaults.Toggle("Show text in category picker", key: .showPickerText)
                Defaults.Toggle("Show amount of games in sidebar", key: .showSortByNumber)
            }
        }
    }
}
