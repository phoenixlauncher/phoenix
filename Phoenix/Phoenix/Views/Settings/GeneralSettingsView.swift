//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    
    @State var steamIsImporting: Bool = false
    @State var invalidFolder: Bool = false
    @State var lastPathComponent: String?
    
    @Default(.steamDetection) var steamDetection
    @Default(.steamFolder) var steamFolder
    @Default(.crossOverDetection) var crossOverDetection
    @Default(.crossOverFolder) var crossOverFolder
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                Defaults.Toggle("Detect Steam games on launch", key: .steamDetection)
                if steamDetection {
                    FolderImportButton(type: "Steam", folder: $steamFolder, lastPathComponent: $lastPathComponent, endPath: "steamapps", invalidFolder: $invalidFolder)
                }
                Defaults.Toggle("Detect CrossOver games on launch", key: .crossOverDetection)
                if crossOverDetection {
                    FolderImportButton(type: "CrossOver", folder: $crossOverFolder, lastPathComponent: $lastPathComponent, endPath: nil, invalidFolder: $invalidFolder)
                }
                Divider()
                Defaults.Toggle("Fetch game metadata", key: .isMetaDataFetchingEnabled)
            }
            .alert("Invalid folder", isPresented: $invalidFolder) {
                VStack {
                    Button("Close", role: .cancel) {}
                }
            } message: {
                Text("The folder path must end with \(lastPathComponent ?? "")")
            }
            .padding(20)
        }
    }
}
