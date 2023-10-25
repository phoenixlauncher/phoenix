//
//  AppearanceSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI
import AppKit

struct AppearanceSettingsView: View {
    
    @AppStorage("accentColorUI")
    private var accentColorUI: Bool = true
    
    @AppStorage("listIconsHidden")
    private var listIconsHidden: Bool = false
    
    @AppStorage("listIconSize")
    private var listIconSize: Double = 24
    
    @AppStorage("picker")
    private var picker: Bool = true
    
    @AppStorage("sortByNumber")
    private var sortByNumber: Bool = false
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: $accentColorUI) {
                    Text("Adaptive Color UI")
                }
                Toggle(isOn: $listIconsHidden) {
                    Text("Hide icons in sidebar")
                }
                if !listIconsHidden {
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
                Toggle(isOn: $picker) {
                    Text("Show text in category picker")
                }
                Toggle(isOn: $sortByNumber) {
                    Text("Show amount of games in sidebar")
                }
            }
        }
    }
}
