//
//  SortBy.swift
//  Phoenix
//
//  Created by jxhug on 1/21/24.
//

import Foundation

enum SortBy: String, Codable, CaseIterable, Identifiable, Defaults.Serializable {
    case platform, status, name, recency

    var id: SortBy { self }
    
    var displayName: String {
        switch self {
        case .platform: return String(localized: "category_Platform")
        case .status: return String(localized: "category_Status")
        case .name: return String(localized: "category_Name")
        case .recency: return String(localized: "category_Recency")
        }
    }
    
    var spaces: String {
        switch self {
        case .platform: return "        \(String(localized: "category_Platform"))"
        case .status: return "       \(String(localized: "category_Status"))"
        case .name: return "         \(String(localized: "category_Name"))"
        case .recency: return "      \(String(localized: "category_Recency"))"
        }
    }
    
    var spacedName: String {
        switch self {
        case .platform: return "       "
        case .status: return "     "
        case .name: return "       "
        case .recency: return "    "
        }
    }
    
    var symbol: String {
        switch self {
        case .platform: return "gamecontroller"
        case .status: return "trophy"
        case .name: return "textformat.abc.dottedunderline"
        case .recency: return "clock"
        }
    }
}
