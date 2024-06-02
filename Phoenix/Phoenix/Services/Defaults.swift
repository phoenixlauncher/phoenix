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
    //app
    static let selectedGame = Key<UUID>("selectedGame", default: UUID())
    static let sortBy = Key<SortBy>("sortBy", default: .platform)
    
    //general
    static let steamDetection = Key<Bool>("steamDetection", default: true)
    static let steamFolder = Key<URL>("steamFolder", default: getApplicationSupportDirectory().appendingPathComponent("steam/steamapps"))
    
    static let crossOverDetection = Key<Bool>("crossOverDetection", default: true)
    static let crossOverFolder = Key<URL>("crossOverFolder", default: URL(fileURLWithPath: "~/Applications/CrossOver"))
    
    static let isMetaDataFetchingEnabled = Key<Bool>("isMetaDataFetchingEnabled", default: true)
    static let getIconFromApp = Key<Bool>("getIconFromApp", default: true)
    
    //appearance
    static let accentColorUI = Key<Bool>("accentColorUI", default: true)
    static let gradientUI = Key<Bool>("gradientUI", default: true)
    static let showStarRating = Key<Bool>("showStarRating", default: true)
    static let gradientHeader = Key<Bool>("gradientHeader", default: false)
    static let showScreenshots = Key<Bool>("showScreenshots", default: true)
    static let screenshotSize = Key<Double>("screenshotSize", default: 220.0)
    static let fadeLeadingScreenshots = Key<Bool>("fadeLeadingScreenshots", default: false)
    
    static let listIconsHidden = Key<Bool>("listIconsHidden", default: false)
    static let listIconSize = Key<Double>("listIconSize", default: 24.0)
    static let showPickerText = Key<Bool>("showPickerText", default: false)
    static let showSortByNumber = Key<Bool>("showSortByNumber", default: true)
    
    static let showSidebarAddGameButton = Key<Bool>("showSidebarAddGameButton", default: false)
    static let showAnimationOfSortByIcon = Key<Bool>("showAnimationOfSortByIcon", default: false)
}
