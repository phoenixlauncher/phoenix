//
//  Platform.swift
//  Phoenix
//
//  Created by jxhug on 1/21/24.
//

import Foundation

enum Platform: String, Codable, CaseIterable, Identifiable {
    case mac, steam, gog, epic, pc, ps, nin, sega, xbox, none

    var id: Platform { self }

    var displayName: String {
        switch self {
        case .mac: return String(localized: "platforms_Mac")
        case .steam: return String(localized: "platforms_Steam")
        case .gog: return String(localized: "platforms_GOG")
        case .epic: return String(localized: "platforms_Epic")
        case .pc: return String(localized: "platforms_PC")
        case .ps: return String(localized: "platforms_Playstation")
        case .nin: return String(localized: "platforms_Nintendo")
        case .sega: return String(localized: "platforms_Sega")
        case .xbox: return String(localized: "platforms_Xbox")
        case .none: return String(localized: "platforms_Other")
        }
    }
}
