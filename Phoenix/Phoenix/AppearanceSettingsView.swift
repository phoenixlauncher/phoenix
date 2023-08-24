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
    
    @AppStorage("listIconSize")
    private var listIconSize: Double = 20
    
    var body: some View {
        Form {
            VStack(spacing: 20) {
                Toggle(isOn: $accentColorUI) {
                    Text("Adaptive Color UI")
                }
                Slider(
                    value: $listIconSize,
                    in: 20...48,
                    step: 4
                ) {
                    Text("List Icon Size")
                } minimumValueLabel: {
                    Text("20 px")
                } maximumValueLabel: {
                    Text("48 px")
                }
                .frame(maxWidth: 225)
            }
        }
    }
}
