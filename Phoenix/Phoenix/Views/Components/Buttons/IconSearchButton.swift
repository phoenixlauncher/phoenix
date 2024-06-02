//
//  IconSearchButton.swift
//  Phoenix
//
//  Created by jxhug on 5/17/24.
//
import SwiftUI

struct IconSearchButton: View {
    
    @Binding var isSearching: Bool
    var icon: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Icon")
                Text("\(String(localized: "platforms_SelectedIcon")): \(icon == "" ? "None" : icon)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            Spacer()
            Button(
                action: {
                    isSearching.toggle()
                    print("search toggled mf")
                },
                label: {
                    Text(LocalizedStringKey("platforms_SearchIcon"))
                }
            )
            .accessibilityLabel(LocalizedStringKey("platforms_SearchIcon"))
        }
        .padding()
    }
}
