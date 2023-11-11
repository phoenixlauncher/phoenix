//
//  GameMetadata.swift
//  Phoenix
//
//  Created by James Hughes on 10/1/23.
//

import SwiftUI

struct GameMetadata: View {
    var field: String
    var value: String
    
    var body: some View {
        if value != "" {
            VStack(alignment: .leading, spacing: 1) {
                Text(field)
                Text(value)
                    .opacity(0.5)
            }
            .font(.system(size: 14.5))
        }
    }
}
