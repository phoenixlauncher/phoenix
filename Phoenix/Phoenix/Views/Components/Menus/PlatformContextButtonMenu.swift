//
//  PlatformContextButtonMenu.swift
//  Phoenix
//
//  Created by jxhug on 4/28/24.
//

import SwiftUI

struct PlatformContextButtonMenu: View {
    let platforms: [Platform]
    let action: ((Platform) -> Void)
    let symbol: String
    let text: String
    
    var body: some View {
        Menu(content: {
            ForEach(platforms) { platform in
                Button(action: { action(platform) }) {
                    AsyncImage(url: URL(string: platform.iconURL)) { image in
                        image.image?.resizable()
                    }
                    .frame(width: 24, height: 24)
                    Text(platform.name)
                }
                .accessibility(identifier: platform.name)
                .padding()
            }
        },
        label: {
            HStack {
                Image(systemName: symbol)
                Text(text)
            }
        })
        .accessibility(identifier: text)
    }
}
