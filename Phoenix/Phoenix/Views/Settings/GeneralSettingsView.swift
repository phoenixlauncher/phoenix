//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                Defaults.Toggle(String(localized: "general_FetchMeta"), key: .isMetaDataFetchingEnabled)
                Defaults.Toggle(String(localized: "general_GetIconFromApp"), key: .getIconFromApp)
            }
            .padding()
        }
        .frame(alignment: .topLeading)
    }
}
