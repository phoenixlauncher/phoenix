//
//  Defaults.swift
//  Phoenix
//
//  Created by James Hughes on 10/25/23.
//

import Defaults
import Foundation

typealias Defaults = _Defaults
typealias Default = _Default

extension Defaults.Keys {
    static let selectedGame = Key<UUID>("selectedGame", default: UUID())
    static let sortBy = Key<PhoenixApp.SortBy>("sortBy", default: .platform)
    
    static let isGameDetectionEnabled = Key<Bool>("isGameDetectionEnabled", default: false)
    static let isMetaDataFetchingEnabled = Key<Bool>("isMetaDataFetchingEnabled", default: true)
    static let accentColorUI = Key<Bool>("accentColorUI", default: true)
    static let listIconsHidden = Key<Bool>("listIconsHidden", default: false)
    static let listIconSize = Key<Double>("listIconSize", default: 24.0)
    static let showPickerText = Key<Bool>("showPickerText", default: false)
    static let showSortByNumber = Key<Bool>("showSortByNumber", default: true)
    static let showAnimationOfSortByIcon = Key<Bool>("showAnimationOfSortByIcon", default: false)
}
