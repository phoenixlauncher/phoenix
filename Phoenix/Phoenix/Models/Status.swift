//
//  Status.swift
//  Phoenix
//
//  Created by jxhug on 1/21/24.
//

import Foundation

enum Status: String, Codable, CaseIterable, Identifiable, CaseIterableEnum {
    case playing, shelved, occasional, backlog, beaten, completed, abandoned, none

    var id: Status { self }

    var displayName: String {
        switch self {
        case .playing: return String(localized: "status_Playing")
        case .shelved: return String(localized: "status_Shelved")
        case .occasional: return String(localized: "status_Occasional")
        case .backlog: return String(localized: "status_Backlog")
        case .beaten: return String(localized: "status_Beaten")
        case .completed: return String(localized: "status_Completed")
        case .abandoned: return String(localized: "status_Abandoned")
        case .none: return String(localized: "status_Other")
        }
    }
}
