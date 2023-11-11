//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("isGameDetectionEnabled")
    private var isGameDetectionEnabled: Bool = false
    
    @AppStorage("isMetadataFetchingEnabled")
    private var isMetadataFetchingEnabled: Bool = true

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: $isGameDetectionEnabled) {
                    Text("Detect Steam games")
                }
                Toggle(isOn: $isMetadataFetchingEnabled) {
                    Text("Fetch game metadata")
                }
            }
        }
    }
}
